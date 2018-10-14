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

    if (!vistype) {
        vistype = get_root_visual_type(screen);
    }

    bg_pixmap = create_bg_pixmap(conn, screen, resolution, color);

    cairo_surface_t *xcb_output = cairo_xcb_surface_create(conn, bg_pixmap, vistype, resolution[0], resolution[1]);
    cairo_t *xcb_ctx = cairo_create(xcb_output);

    const int y_pos = 75; /* percentage of the screen height */
    const int psw_bottom_margin = 40;

    /* Password field */

    const char *psw_placeholder = "Type password to unlock…";

    const double psw_dots_radius = 5;
    const double psw_dots_spacing = 8;

    double psw_height = psw_dots_radius * 5;
    double psw_width = 400;

    if (input_position) {
        psw_width = input_position * (psw_dots_radius * 2) + (input_position - 1) * psw_dots_spacing;
    }

    cairo_surface_t *psw_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, psw_width, psw_height);;
    cairo_t *psw_ctx = cairo_create(psw_surface);

    if (!input_position) {
        /* Display password placeholder */

        cairo_text_extents_t extents;
        double x, y;

        cairo_set_source_rgba(psw_ctx, 255.0, 255.0, 255.0, 1);
        cairo_select_font_face(psw_ctx, "Noto Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
        cairo_set_font_size(psw_ctx, 18.0);

        cairo_text_extents(psw_ctx, psw_placeholder, &extents);
        x = psw_width/2 - (extents.width/2 + extents.x_bearing);
        y = psw_height/2 - (extents.height/2 + extents.y_bearing);

        cairo_move_to(psw_ctx, x, y);
        cairo_show_text(psw_ctx, psw_placeholder);
        cairo_close_path(psw_ctx);
    }

    /* Auth state message */

    const double msg_width = 400;
    const double msg_height = 30;

    cairo_surface_t *msg_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, msg_width, msg_height);
    cairo_t *msg_ctx = cairo_create(msg_surface);

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

        if (input_position) {
            cairo_set_source_rgba(psw_ctx, 255.0, 255.0, 255.0, 1);
            for (int x = psw_dots_radius; x < psw_width; x += (psw_dots_radius*2 + psw_dots_spacing)) {
                cairo_arc(psw_ctx, x, psw_height/2.0, psw_dots_radius, 0, 2*M_PI);
                cairo_fill(psw_ctx);
            }
        }

        /* Display a text of the current PAM state */

        char *text = NULL;
        cairo_set_source_rgba(msg_ctx, 255.0, 255.0, 255.0, 0.9);
        cairo_select_font_face(msg_ctx, "Noto Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
        cairo_set_font_size(msg_ctx, 14.0);

        switch (auth_state) {
            case STATE_AUTH_VERIFY:
                text = "";
                break;
            case STATE_AUTH_LOCK:
                text = "Locking…";
                break;
            case STATE_AUTH_WRONG:
                text = "Sorry, try again.";
                break;
            case STATE_I3LOCK_LOCK_FAILED:
                text = "Lock failed!";
                break;
            default:
                break;
        }

        if (text) {
            cairo_text_extents_t extents;
            double x, y;

            cairo_text_extents(msg_ctx, text, &extents);
            x = msg_width/2 - (extents.width/2 + extents.x_bearing);
            y = msg_height/2 - (extents.height/2 + extents.y_bearing);

            cairo_move_to(msg_ctx, x, y);
            cairo_show_text(msg_ctx, text);
            cairo_close_path(msg_ctx);
        }

    }

    if (xr_screens > 0) {

        /* Composite the unlock indicator in the middle of each screen. */
        for (int screen = 0; screen < xr_screens; screen++) {
            double x, y;

            x = (xr_resolutions[screen].x + ((xr_resolutions[screen].width / 2) - (psw_width / 2)));
            y = ceil(xr_resolutions[screen].height * y_pos / 100);
            cairo_set_source_surface(xcb_ctx, psw_surface, x, y);
            cairo_rectangle(xcb_ctx, x, y, psw_width, psw_height);
            cairo_fill(xcb_ctx);

            x = (xr_resolutions[screen].x + ((xr_resolutions[screen].width / 2) - (msg_width / 2)));
            y = y + psw_height + psw_bottom_margin;
            cairo_set_source_surface(xcb_ctx, msg_surface, x, y);
            cairo_rectangle(xcb_ctx, x, y, msg_width, msg_height);
            cairo_fill(xcb_ctx);
        }

    } else {

        /* We have no information about the screen sizes/positions, so we just
         * place the unlock indicator in the middle of the X root window and
         * hope for the best. */
        double x, y;

        x = (last_resolution[0] / 2) - (psw_width / 2);
        y = ceil(last_resolution[1] * y_pos / 100);
        cairo_set_source_surface(xcb_ctx, psw_surface, x, y);
        cairo_rectangle(xcb_ctx, x, y, psw_width, psw_height);
        cairo_fill(xcb_ctx);

        x = (last_resolution[0] / 2) - (msg_width / 2);
        y = y + psw_height + psw_bottom_margin;
        cairo_set_source_surface(xcb_ctx, msg_surface, x, y);
        cairo_rectangle(xcb_ctx, x, y, msg_width, msg_height);
        cairo_fill(xcb_ctx);
    }

    cairo_surface_destroy(xcb_output);
    cairo_surface_destroy(psw_surface);
    cairo_surface_destroy(msg_surface);
    cairo_destroy(xcb_ctx);
    cairo_destroy(psw_ctx);
    cairo_destroy(msg_ctx);
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
