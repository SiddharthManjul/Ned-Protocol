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

function InitDb()
    db:exec(USERS)
    db:exec(POSTS)
    db:exec(LIKES)
    db:exec(MESSAGES)
end

InitDb()

Handlers.add("NedProtocol.RegisterUser",

    function(msg)
        return msg.Action == "RegisterUser"
    end,

    function(msg)
        local authorCount = #dbAdmin:exec(string.format([[SELECT * FROM Authors WHERE PID = "%s";]], msg.From))
        if authorCount > 0 then
            Send({Target = msg.From, Action = "Registered", Data = "Already registered"})
            print("Author already registered")
            return "Already Registered"
        end
        local Name = msg.Name or 'anon'
        dbAdmin:exec(string.format([[INSERT INTO Authors (PID, Name) VALUES ("%s", "%s");]], msg.From, Name))
        Send({Target = msg.From, Action = "NedProtocol.Registered", Data = "Successfully Registered."})
        print("Registered " .. Name)
    end

)