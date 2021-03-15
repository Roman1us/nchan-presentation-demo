var fs = require("fs").promises;
var crypto = require("crypto");

function generate_room_id(r) {
    return Math.random().toString(36).substring(2);
}

function process_message(r) {
    var uid = crypto.createHash("md5").update(r.variables.uid_got || r.variables.uid_set).digest("hex");

    var message = "[" + (new Date()).toISOString() + "]:" + uid + ":" + r.requestText.trim();
    var file = r.variables.chat_history_location + r.variables.room;

    fs.appendFile(file, message + "\n")
        .then(() => r.subrequest("/post-process", {
                args: "chatid=" + r.variables.room,
                body: message,
                method: "POST"
            })
            .then(() => r.return(201))
            .catch(() => r.return(401))
        )
        .catch(() => r.return(401))
}

export default { generate_room_id, process_message };
