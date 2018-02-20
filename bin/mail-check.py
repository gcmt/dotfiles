#!/usr/bin/env python

import re
import os
import sys
import time
import imaplib
import subprocess


try:
    HOSTNAME = os.environ['FASTMAIL_HOSTNAME']
    USERNAME = os.environ['FASTMAIL_USERNAME']
    PASSWORD = os.environ['FASTMAIL_PASSWORD']
except KeyError:
    print('ERROR: Missing account credentials', file=sys.stderr)
    sys.exit(1)


def notify(msg):
    subprocess.Popen(f"notify-send 'Fastmail' '{msg}'", shell=True)


# When resuming the system, the network remains unreachable just after
# nm-online returns successfully. This functions tries to mitigate the problem
# using timeouts
def connect(hostname, timeout=0, interval=0.1):
    start = time.time()
    while True:
        try:
            return imaplib.IMAP4_SSL(hostname)
        except OSError as e:
            # catch OSError: [Errno 101] Network is unreachable
            if time.time() - start > timeout:
                raise
            time.sleep(interval)


def get_unread_mailboxes(conn):

    unread = {}
    _, data = conn.list()

    for line in data:
        match = re.match(r'\(.*?\) ".*" (.*)', line.decode('utf-8'))
        if not match:
            continue
        mailbox = match.group(1)
        _, status = conn.status(f'"{mailbox}"', '(UNSEEN)')
        match = re.search(r'\(UNSEEN (\d+)\)', status[0].decode('utf-8'))
        if not match:
            continue
        unseen = int(match.group(1))
        if unseen > 0:
            unread[mailbox] = unseen

    return unread


def main():

    conn = connect(HOSTNAME, timeout=5, interval=0.5)
    conn.login(USERNAME, PASSWORD)

    unread_mailboxes = get_unread_mailboxes(conn)
    exclude = ('Trash', 'Spam', 'Sent', 'Queue', 'Drafts', 'Archive', 'Notes', 'LinkedIn', 'News')
    unread_mailboxes = {k: v for k, v in unread_mailboxes.items() if k not in exclude}
    unread_count = sum(unread_mailboxes.values())

    if unread_mailboxes:
        filler = "a total of " if len(unread_mailboxes) > 1 else ""
        messages = "message" if unread_count == 1 else "messages"
        mailboxes = ', '.join(unread_mailboxes)
        msg = f"You have {filler}{unread_count} unread {messages} in {mailboxes}"
        notify(msg)
        print(msg)

    conn.logout()


if __name__ == '__main__':
    try:
        main()
    except imaplib.IMAP4.error as e:
        print(f'ERROR: {e}', file=sys.stderr)
        sys.exit(1)
