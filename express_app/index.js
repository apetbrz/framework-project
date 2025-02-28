const express = require("express");
const bcrypt = require("bcrypt");
const path = require("path");

const port = 3001;

const app = express();

app.use(express.json());

app.get("/hello", (req, res) => {
    res.json({message: "Hello World"})
});

app.get("/static", (req, res) => {
    res.sendFile(path.join(__dirname, "static/express_static_page.html"))
});

app.post("/hash", async (req, res) => {
    let msg = req.body;
    console.table(msg);
    let hashed_pw = await bcrypt.hash(msg.password, 8);

    console.dir(req.ip);
    console.table(req.body);
    console.log("out: " + hashed_pw);
    res.json({password: hashed_pw});
})

app.listen(port, () => {
    console.log('Server started on port ' + port);
});