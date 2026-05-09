import QtQml

QtObject {
    id: root

    readonly property list<QtObject> sources: [
        MusicSource {
            label: "Pop 📻🎶"
            url: "https://youtube.com/playlist?list=PLMC9KNkIncKtPzgY-5rmhvj7fax8fdxoj"
        },
        MusicSource {
            label: "Dance 📻🎶"
            url: "https://dancewave.online:443/dance.mp3"
        },
        MusicSource {
            label: "Lofi Radio ☕️🎶"
            url: "https://play.streamafrica.net/lofiradio"
        },
        MusicSource {
            label: "96.3 Easy Rock 📻🎶"
            url: "https://radio-stations-philippines.com/easy-rock"
        },
        MusicSource {
            label: "Rock 📻🎶"
            url: "https://www.youtube.com/playlist?list=PL6Lt9p1lIRZ311J9ZHuzkR5A3xesae2pk"
        },
        MusicSource {
            label: "Ghibli Music 🎻🎶"
            url: "https://youtube.com/playlist?list=PLNi74S754EXbrzw-IzVhpeAaMISNrzfUy&si=rqnXCZU5xoFhxfOl"
        },
        MusicSource {
            label: "Top Youtube Music 2023 ☕️🎶"
            url: "https://youtube.com/playlist?list=PLDIoUOhQQPlXr63I_vwF9GD8sAKh77dWU&si=y7qNeEVFNgA-XxKy"
        },
        MusicSource {
            label: "Chillhop ☕️🎶"
            url: "https://stream.zeno.fm/fyn8eh3h5f8uv"
        },
        MusicSource {
            label: "SmoothChill ☕️🎶"
            url: "https://media-ssl.musicradio.com/SmoothChill"
        },
        MusicSource {
            label: "Smooth UK ☕️🎶"
            url: "https://icecast.thisisdax.com/SmoothUKMP3"
        },
        MusicSource {
            label: "Relaxing Music ☕️🎶"
            url: "https://youtube.com/playlist?list=PLMIbmfP_9vb8BCxRoraJpoo4q1yMFg4CE"
        },
        MusicSource {
            label: "Youtube Remix 📻🎶"
            url: "https://youtube.com/playlist?list=PLeqTkIUlrZXlSNn3tcXAa-zbo95j0iN-0"
        },
        MusicSource {
            label: "_Headbangers 🎵"
            url: "https://youtube.com/playlist?list=PLLosUj2DlL27g7BfUwAEoBr2Cr5EY0aP8"
        },
        MusicSource {
            label: "_Motorway 🎵"
            url: "https://youtube.com/playlist?list=PLLosUj2DlL2613eXf-20WT6VQnZenrg0X"
        },
        MusicSource {
            label: "_Carriageway 🎵"
            url: "https://youtube.com/playlist?list=PLLosUj2DlL26qNYOBo0_9yW9za1Egwp_y"
        },
        MusicSource {
            label: "_Classics 🎵"
            url: "https://youtube.com/playlist?list=PLLosUj2DlL260MDLEfAej9CqFqdycTf3X"
        },
        MusicSource {
            label: "_Metal 🎵"
            url: "https://youtube.com/playlist?list=PLLosUj2DlL246iFzN3q8-cYCA43YBxv_z"
        },
        MusicSource {
            label: "_Limo 🎵"
            url: "https://youtube.com/playlist?list=PLLosUj2DlL27x3iZrv2ElvTK7-iQzQKYY"
        },
        MusicSource {
            label: "_80s 90s 2000s 🎵"
            url: "https://youtube.com/playlist?list=PLLosUj2DlL24FAtYVcivVfHImRsu-ocj4"
        },
        MusicSource {
            label: "_Hard Rock 🎵"
            url: "https://youtube.com/playlist?list=PLLosUj2DlL25A5u32lnZXtc_AUy-u2AUd"
        }
    ]

    component MusicSource: QtObject {
        required property string label
        required property string url
        readonly property bool playlist: url.includes("playlist")
        readonly property list<string> command: playlist ? ["uwsm", "app", "--", "mpv", "--vid=no", "--shuffle", url] : ["uwsm", "app", "--", "mpv", url]
    }
}
