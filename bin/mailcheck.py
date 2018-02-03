#!/usr/bin/env python

import re
import os
import sys
import imaplib
import subprocess


def notify(msg, critical=False):
    flag = "-u critical" if critical else ""
    env = "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
    subprocess.Popen(f"{env} notify-send {flag} 'Fastmail' '{msg}'", shell=True)


try:
    HOSTNAME = os.environ['FASTMAIL_HOSTNAME']
    USERNAME = os.environ['FASTMAIL_USERNAME']
    PASSWORD = os.environ['FASTMAIL_PASSWORD']
except KeyError:
    print('ERROR: Missing account credentials', file=sys.stderr)
    sys.exit(1)


if __name__ == '__main__':

    try:
        conn = imaplib.IMAP4_SSL(HOSTNAME)
    except Exception as e:
        print(f'ERROR: {e}', file=sys.stderr)
        sys.exit(1)

    try:
        conn.login(USERNAME, PASSWORD)
    except Exception as e:
        print(f'ERROR: {e}', file=sys.stderr)
        sys.exit(1)

    res, data = conn.list()
    if res != 'OK':
        print('ERROR: Unable to list mailboxes', file=sys.stderr)
        sys.exit(1)

    unread_count = 0
    unread_mailboxes = []
    for line in data:
        match = re.match(r'\(.*?\) ".*" (.*)', line.decode('utf-8'))
        if not match:
            continue
        mailbox = match.group(1)
        if mailbox in ('Trash', 'Spam', 'Sent', 'Queue', 'Drafts', 'Archive', 'Notes'):
            continue
        res, status = conn.status(f'"{mailbox}"', '(UNSEEN)')
        if res != 'OK':
            continue
        match = re.search(r'\(UNSEEN (\d+)\)', status[0].decode('utf-8'))
        if not match:
            continue
        unseen = int(match.group(1))
        if unseen > 0:
            unread_mailboxes.append(mailbox)
            unread_count += unseen

    if unread_mailboxes:
        filler = "a total of " if len(unread_mailboxes) > 1 else ""
        messages = "message" if unread_count == 1 else "messages"
        mailboxes = ', '.join(unread_mailboxes)
        notify(f"You have {filler}{unread_count} unread {messages} in {mailboxes}")
