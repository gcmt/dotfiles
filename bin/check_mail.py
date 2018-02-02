#!/usr/bin/env python

import re
import os
import sys
import imaplib
import subprocess
import configparser


CREDENTIALS_FILE = os.path.expanduser('~/.fastmail')
HOSTNAME = 'imap.fastmail.com'


def notify(msg, critical=False):
    flag = "-u critical" if critical else ""
    subprocess.Popen("notify-send {} 'Fastmail' '{}'".format(flag, msg), shell=True)


config = configparser.ConfigParser()
config.read([CREDENTIALS_FILE])

try:
    USERNAME = config['credentials']['username']
    PASSWORD = config['credentials']['password']
except KeyError:
    print('ERROR: Missing credentials', file=sys.stderr)
    sys.exit(1)


if __name__ == '__main__':

    try:
        conn = imaplib.IMAP4_SSL(HOSTNAME)
    except Exception as e:
        print('ERROR: Unable to connect', file=sys.stderr)
        sys.exit(1)

    try:
        conn.login(USERNAME, PASSWORD)
    except Exception as e:
        print('LOGIN ERROR: Incorrect username or password', file=sys.stderr)
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
        res, status = conn.status( '"{}"'.format(mailbox), '(UNSEEN)')
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
        notify("You have {}{} unread {} in {}".format(
            "a total of " if len(unread_mailboxes) > 1 else "",
            unread_count,
            "message" if unread_count == 1 else "messages",
            ', '.join(unread_mailboxes)
        ))
