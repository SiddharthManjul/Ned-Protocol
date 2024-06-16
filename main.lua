-- aos process: G1qe3_tQIIZRqUKMiRaQz4-jrefPyft4ng3TXRor2So

local sqlite3 = require('lsqlite3')
db = db or sqlite3.open_memory()
dbAdmin = require('@rakis/DbAdmin').new(db)


-- Database schema
USERS = [[
  CREATE TABLE IF NOT EXISTS Users (
    PID TEXT PRIMARY KEY,
    Name TEXT
  );
]]

POSTS = [[
  CREATE TABLE IF NOT EXISTS Posts (
    ID TEXT PRIMARY KEY,
    PID TEXT,
    Title TEXT,
    Body TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PID) REFERENCES Authors(PID)
  );
]]

LIKES = [[
  CREATE TABLE IF NOT EXISTS Likes (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id TEXT,
    user_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(ID)
  );
]]

MESSAGES = [[
  CREATE TABLE IF NOT EXISTS Messages (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id TEXT,
    user_id TEXT,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(ID)
  );
]]