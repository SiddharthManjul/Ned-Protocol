-- process id : p8NeaI59y_pSs8WkNuZyF5-pqTrvW2wMGBew95FMZV4

local sqlite3 = require('lsqlite3')
local base64 = require(".base64")
db = db or sqlite3.open_memory()
dbAdmin = require('@rakis/DbAdmin').new(db)

USERS = [[
    CREATE TABLE IF NOT EXISTS Users (
        PID TEXT PRIMARY KEY
        Name TEXT
        Username TEXT
        Password TEXT
    )
]]

function InitDb()
    db:exec(USERS)
end

InitDb()


Handlers.add("NedProtocol.SignUpUser",

    function(msg)
        return msg.Action == "SignUpUser"
    end,

    function(msg)
        local userCount = #dbAdmin:exec(string.format([[SELECT * FROM Users WHERE PID = "%s";]], msg.From))
        if userCount > 0 then
            Send({Target = msg.From, Action = "UserSignedUp", Data = "Already Signed Up."})
            print("User already signed up.")
            return "Already Signed Up"
        end

        local Name = msg.Name or 'anon'
        local Username = msg.Username .. ".ned"
        local Password = base64.encode(msg.Password)
        local SignedUser = dbAdmin:exec(string.format([[INSERT INTO Users (PID, Name, Username, Password) VALUES ("%s", "%s", "%s", "%s",);]], msg.From, Name, Username, Password))

        if SignedUser then
            Send({Target = msg.From, Action = "NedProtocol.UserSignedUp", Data = "Successfully Signed Up"})
            print(Username .. "Signed Up!")
        else 
            Send({Target = msg.From, Data = "Not Signed"})
            print("Failed to Sign Up")
        end
    end
)

Handler.add("NedProtocol.UserLogin",

    function(msg)
        return msg.Action == "UserLogin"
    end,

    function(msg)
        
        
)