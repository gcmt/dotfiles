/*
 * vim:ts=4:sw=4:expandtab
 *
 * © 2010 Michael Stapelberg
 *
 * See LICENSE for licensing information
 *
 */
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <xcb/xcb.h>
#include <ev.h>
#include <cairo.h>
#include <cairo/cairo-xcb.h>

#include "i3lock.h"
#include "xcb.h"
#include "unlock_indicator.h"
#include "randr.h"
#include "dpi.h"

/*******************************************************************************
 * Variables defined in i3lock.c.
 ******************************************************************************/

extern bool debug_mode;

/* The current position in the input buffer. Useful to determine if any
 * characters of the password have already been entered or not. */
int input_position;

/* The lock window. */
extern xcb_window_t win;

/* The current resolution of the X11 root window. */
extern uint32_t last_resolution[2];

/* Whether the unlock indicator is enabled (defaults to true). */
extern bool unlock_indicator;

/* List of pressed modifiers, or NULL if none are pressed. */
extern char *modifier_string;

/* A Cairo surface containing the specified image (-i), if any. */
extern cairo_surface_t *img;

/* Whether the image should be tiled. */
extern bool tile;
/* The background color to use (in hex). */
extern char color[7];

/* Whether the failed attempts should be displayed. */
extern bool show_failed_attempts;
/* Number of failed unlock attempts. */
extern int failed_attempts;

/*******************************************************************************
 * Variables defined in xcb.c.
 ******************************************************************************/

/* The root screen, to determine the DPI. */
extern xcb_screen_t *screen;

/*******************************************************************************
 * Local variables.
 ******************************************************************************/

/* Lock icon */
cairo_surface_t *lock_image;

/* Cache the screen’s visual, necessary for creating a Cairo context. */
static xcb_visualtype_t *vistype;

/* Maintain the current unlock/PAM state to draw the appropriate unlock
 * indicator. */
unlock_state_t unlock_state;
auth_state_t auth_state;

/*
 * Draws global image with fill color onto a pixmap with the given
 * resolution and returns it.
 *
 */
xcb_pixmap_t draw_image(uint32_t *resolution) {

    xcb_pixmap_t bg_pixmap = XCB_NONE;
    const double scaling_factor = get_dpi_value() / 96.0;

    if (!vistype) {
        vistype = get_root_visual_type(screen);
    }

    bg_pixmap = create_bg_pixmap(conn, screen, resolution, color);

    cairo_surface_t *xcb_output = cairo_xcb_surface_create(conn, bg_pixmap, vistype, resolution[0], resolution[1]);
    cairo_t *xcb_ctx = cairo_create(xcb_output);

    const int top_margin = 300;
    const int psw_top_margin = 60;
    const int msg_top_margin = 60;

    /* Password field */

    const double psw_dots_radius = ceil(scaling_factor * 5);
    const double psw_dots_spacing = ceil(scaling_factor * 8);

    double psw_height = psw_dots_radius * 2;
    double psw_width = 1;

    if (input_position) {
        psw_width = input_position * (psw_dots_radius * 2) + (input_position - 1) * psw_dots_spacing;
    }

    cairo_surface_t *psw_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, psw_width, psw_height);;
    cairo_t *psw_ctx = cairo_create(psw_surface);

    /* Auth state message */

    const double msg_width = 400;
    const double msg_height = 50;

    cairo_surface_t *msg_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, msg_width, msg_height);
    cairo_t *msg_ctx = cairo_create(msg_surface);

    /* Lock icon */

    const char *lock_path = "/usr/share/i3lock/resources/lock.png";
    double lock_width = 35;
    double lock_height = 0;
    double lock_scaling = 1.0;

    if (lock_image == NULL) {
        lock_image = cairo_image_surface_create_from_png(lock_path);
    }

    bool image_loaded = cairo_surface_status(lock_image) == CAIRO_STATUS_SUCCESS;

    if (image_loaded) {
        const double lock_image_width = cairo_image_surface_get_width(lock_image);
        const double lock_image_height = cairo_image_surface_get_height(lock_image);
        lock_scaling = lock_width / lock_image_width;
        lock_height = floor(lock_image_height * lock_scaling);
    }

    cairo_surface_t *lock_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, lock_width, lock_height);
    cairo_t *lock_ctx = cairo_create(lock_surface);

    if (image_loaded) {
        cairo_scale(lock_ctx, lock_scaling, lock_scaling);
        cairo_set_source_surface(lock_ctx, lock_image, 0, 0);
        cairo_paint(lock_ctx);
    }

    /* Display background image */

    if (img) {
        if (!tile) {
            cairo_set_source_surface(xcb_ctx, img, 0, 0);
            cairo_paint(xcb_ctx);
        } else {
            /* create a pattern and fill a rectangle as big as the screen */
            cairo_pattern_t *pattern;
            pattern = cairo_pattern_create_for_surface(img);
            cairo_set_source(xcb_ctx, pattern);
            cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REPEAT);
            cairo_rectangle(xcb_ctx, 0, 0, resolution[0], resolution[1]);
            cairo_fill(xcb_ctx);
            cairo_pattern_destroy(pattern);
        }
    } else {
        char strgroups[3][3] = {{color[0], color[1], '\0'},
                                {color[2], color[3], '\0'},
                                {color[4], color[5], '\0'}};
        uint32_t rgb16[3] = {(strtol(strgroups[0], NULL, 16)),
                             (strtol(strgroups[1], NULL, 16)),
                             (strtol(strgroups[2], NULL, 16))};
        cairo_set_source_rgb(xcb_ctx, rgb16[0] / 255.0, rgb16[1] / 255.0, rgb16[2] / 255.0);
        cairo_rectangle(xcb_ctx, 0, 0, resolution[0], resolution[1]);
        cairo_fill(xcb_ctx);
    }

    if (unlock_indicator && (unlock_state >= STATE_KEY_PRESSED || auth_state > STATE_AUTH_IDLE)) {

        /* Print each password character as a dot */

        cairo_scale(psw_ctx, scaling_factor, scaling_factor);
        cairo_set_source_rgba(psw_ctx, 255.0, 255.0, 255.0, 1);
        for (int x = psw_dots_radius; x < psw_width; x += (psw_dots_radius*2 + psw_dots_spacing)) {
            cairo_arc(psw_ctx, x, psw_height/2.0, psw_dots_radius, 0, 2*M_PI);
            cairo_fill(psw_ctx);
        }

        /* Display a text of the current PAM state */

        char *text = NULL;
        cairo_set_source_rgb(msg_ctx, 255.0, 255.0, 255.0);
        cairo_select_font_face(msg_ctx, "Noto Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
        cairo_set_font_size(msg_ctx, 14.0);

        switch (auth_state) {
            case STATE_AUTH_VERIFY:
                text = "verifying…";
                break;
            case STATE_AUTH_LOCK:
                text = "locking…";
                break;
            case STATE_AUTH_WRONG:
                text = "wrong password!";
                break;
            case STATE_I3LOCK_LOCK_FAILED:
                text = "lock failed!";
                break;
            default:
                break;
        }

        if (text) {
            cairo_text_extents_t extents;
            double x, y;

            cairo_text_extents(msg_ctx, text, &extents);
            x = msg_width/2 - extents.width/2;
            y = extents.height/2 - extents.y_bearing;

            cairo_move_to(msg_ctx, x, y);
            cairo_show_text(msg_ctx, text);
            cairo_close_path(msg_ctx);
        }

    }

    if (xr_screens > 0) {

        /* Composite the unlock indicator in the middle of each screen. */
        for (int screen = 0; screen < xr_screens; screen++) {
            double x, y;
            int offset = top_margin;

            if (image_loaded) {
                x = (xr_resolutions[screen].x + ((xr_resolutions[screen].width / 2) - (lock_width / 2)));
                y = (xr_resolutions[screen].y + ((xr_resolutions[screen].height / 2) - (lock_height / 2))) + offset;
                cairo_set_source_surface(xcb_ctx, lock_surface, x, y);
                cairo_paint(xcb_ctx);
                offset += psw_top_margin;
            }

            x = (xr_resolutions[screen].x + ((xr_resolutions[screen].width / 2) - (psw_width / 2)));
            y = (xr_resolutions[screen].y + ((xr_resolutions[screen].height / 2) - (psw_height / 2))) + offset;
            cairo_set_source_surface(xcb_ctx, psw_surface, x, y);
            cairo_rectangle(xcb_ctx, x, y, psw_width, psw_height);
            cairo_fill(xcb_ctx);
            offset += msg_top_margin;

            x = (xr_resolutions[screen].x + ((xr_resolutions[screen].width / 2) - (msg_width / 2)));
            y = (xr_resolutions[screen].y + ((xr_resolutions[screen].height / 2) - (msg_height / 2))) + offset;
            cairo_set_source_surface(xcb_ctx, msg_surface, x, y);
            cairo_rectangle(xcb_ctx, x, y, msg_width, msg_height);
            cairo_fill(xcb_ctx);
        }

    } else {

        /* We have no information about the screen sizes/positions, so we just
         * place the unlock indicator in the middle of the X root window and
         * hope for the best. */
        double x, y;
        int offset = top_margin;

        if (image_loaded) {
            x = (last_resolution[0] / 2) - (lock_width / 2);
            y = (last_resolution[1] / 2) - (lock_height / 2) + offset;
            cairo_set_source_surface(xcb_ctx, lock_surface, x, y);
            cairo_paint(xcb_ctx);
            offset += psw_top_margin;
        }

        x = (last_resolution[0] / 2) - (psw_width / 2);
        y = (last_resolution[1] / 2) - (psw_height / 2) + offset;
        cairo_set_source_surface(xcb_ctx, psw_surface, x, y);
        cairo_rectangle(xcb_ctx, x, y, psw_width, psw_height);
        cairo_fill(xcb_ctx);
        offset += msg_top_margin;

        x = (last_resolution[0] / 2) - (msg_width / 2);
        y = (last_resolution[1] / 2) - (msg_height / 2) + offset;
        cairo_set_source_surface(xcb_ctx, msg_surface, x, y);
        cairo_rectangle(xcb_ctx, x, y, msg_width, msg_height);
        cairo_fill(xcb_ctx);
    }

    cairo_surface_destroy(xcb_output);
    cairo_surface_destroy(psw_surface);
    cairo_surface_destroy(lock_surface);
    cairo_destroy(xcb_ctx);
    cairo_destroy(psw_ctx);
    cairo_destroy(lock_ctx);
    return bg_pixmap;
}

/*
 * Calls draw_image on a new pixmap and swaps that with the current pixmap
 *
 */
void redraw_screen(void) {
    DEBUG("redraw_screen(unlock_state = %d, auth_state = %d)\n", unlock_state, auth_state);
    xcb_pixmap_t bg_pixmap = draw_image(last_resolution);
    xcb_change_window_attributes(conn, win, XCB_CW_BACK_PIXMAP, (uint32_t[1]){bg_pixmap});
    /* XXX: Possible optimization: Only update the area in the middle of the
     * screen instead of the whole screen. */
    xcb_clear_area(conn, 0, win, 0, 0, last_resolution[0], last_resolution[1]);
    xcb_free_pixmap(conn, bg_pixmap);
    xcb_flush(conn);
}

/*
 * Hides the unlock indicator completely when there is no content in the
 * password buffer.
 *
 */
void clear_indicator(void) {
    if (input_position == 0) {
        unlock_state = STATE_STARTED;
    } else
        unlock_state = STATE_KEY_PRESSED;
    redraw_screen();
}
