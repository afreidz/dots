import json
import sys
from argparse import ArgumentParser

import dbus

session_bus = dbus.SessionBus()
bus_data = ("org.mpris.MediaPlayer2.spotify", "/org/mpris/MediaPlayer2")
spotify_bus = session_bus.get_object(*bus_data)
interface = dbus.Interface(spotify_bus, "org.freedesktop.DBus.Properties")
metadata = interface.Get("org.mpris.MediaPlayer2.Player", "Metadata")

parser = ArgumentParser()
parser.add_argument('--artist', action='store_true')
parser.add_argument('--song', action='store_true')
parser.add_argument('--album', action='store_true')
parser.add_argument('--format', default='json')


def main():
    args = parser.parse_args()

    data = dict()

    if args.artist:
        data['artist'] = str(next(iter(metadata['xesam:albumArtist'])))

    if args.song:
        data['song'] = str(metadata['xesam:title'])

    if args.album:
        data['album'] = str(metadata['xesam:album'])

    sys.stdout.write(json.dumps(data))


if __name__ == '__main__':
    main()
