CONFIG = {}

PACK_ID = "quartz"
CONFIG_PATH = pack.shared_file(PACK_ID, "config.json")
CONTENT_PACKS = {}

CHUNK_LOADING_DISTANCE = 0

CACHED_DATA = {over = false}

COLORS = {
    red =    "[#ff0000]",
    yellow = "[#ffff00]",
    blue =   "[#0000FF]",
    black =  "[#000000]",
    green =  "[#00FF00]",
    white =  "[#FFFFFF]",
    gray =   "[#4d4d4d]"
}

PLAYER_LIST = {}
TEMP_PLAYERS = {}
CLIENT_PLAYER = nil
CLIENT = nil
SERVER = nil