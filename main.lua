-- aos process: G1qe3_tQIIZRqUKMiRaQz4-jrefPyft4ng3TXRor2So

local sqlite3 = require('lsqlite3')
db = db or sqlite3.open_memory()
dbAdmin = require('@rakis/DbAdmin').new(db)


-- Database schema
USERS = [[
  CREATE TABLE IF NOT EXISTS Users (
    PID TEXT PRIMARY KEY,
    Name TEXT
    Username TEXT
  );
]]

POSTS = [[
  CREATE TABLE IF NOT EXISTS Posts (
    ID TEXT PRIMARY KEY,
    PID TEXT,
    Title TEXT,
    Body TEXT,
    Image TEXT
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PID) REFERENCES Userss(PID)
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
        local userCount = #dbAdmin:exec(string.format([[SELECT * FROM Users WHERE PID = "%s";]], msg.From))
        if userCount > 0 then
            Send({Target = msg.From, Action = "Registered", Data = "Already registered"})
            print("User already registered")
            return "Already Registered"
        end
        local Username = msg.Username .. ".ned"
        local Name = msg.Name or 'anon'
        dbAdmin:exec(string.format([[INSERT INTO Users (PID, Name, Username) VALUES ("%s", "%s", "%s");]], msg.From, Name, Username))
        Send({Target = msg.From, Action = "NedProtocol.Registered", Data = "Successfully Registered."})
        print("Registered " .. Name)
    end

)

-- Function to convert image into base64 string
local base64 = require(".base64")
local function ConvertToBase64(Data)
    return base64.encode(Data)
end

Handlers.add("NedProtocol.CreatePost",

    function(msg)
        return msg.Action == "CreatePost"
    end,

    function(msg)
        local user = dbAdmin:exec(string.format([[SELECT PID, Name FROM Users WHERE PID = "%s";]], msg.From))[1]
        if user then
            local base64Image = ""
            if msg.ImagePath then
                local imageData = readFile(msg.ImagePath)
                base64Image = ConvertToBase64(imageData)
            end
            dbAdmin:exec(string.format([[INSERT INTO Posts (ID, PID, Title, Body, Image) VLAUES ("%s", "%s", "%s", "%s", "%s");]],
                msg.Id, user.PID, msg.Title, msg.Data, msg.base64Image))
            Send({Target = msg.From, Data = "Write-up Posted."})
            print("New Write-up Posted.")
        else 
            Send({Target = msg.From, Data = "Not Registered"})
            print("Not Registered as Writer, can't post!")
        end
    end
)

Handlers.add("NedProtocol.GetPosts",

    function(msg)
        return msg.Action == "GetPosts"
    end,

    function(msg)
        local posts = dbAdmin:exec([[
            SELECT p.ID, p.Title, u.Name as "User" FROM Posts p LEFT OUTER JOIN Users u ON p.PID = u.PID;
        ]])
        print("Listing " ..#posts .. " posts")
        Send({Target = msg.From, Action = "NedProtocol.Posts", Data = require('json').encode(posts)})
    end
)

Handlers.add("NedProtocol.GetPost",

    function(msg)
        return msg.Action == "GetPost"
    end,

    function(msg)
        local post = dbAdmin:exec(string.format([[
            SELECT p.ID, p.TITLE, u.Name as "User", p.Body, p.Image FROM Posts p LEFT OUTER JOIN Users u ON p.PID = u.PID WHERE p.ID = "%s";
        ]], msg["Post-Id"]))[1]
        Send({Target = msg.From, Action = "Get-Response", Data = require('json').encode(post)})
        print(post)
    end
)

Handlers.add("NedProtocol.LikePost",

    function(msg)
        return msg.Action == "LikePost"
    end,

    function(msg)
        dbAdmin:exec(string.format([[INSERT INTO Likes (post_id, user_id) VALUES ("%s", "%s");]], msg.post_id, msg.user_id))
        Send({Target = msg.From, Action = "Like", Data = "Post Liked Successfully"})
        print("Post Liked Successfully")
    end
)

