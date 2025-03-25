const express = require("express");
const bcrypt = require("bcrypt");
const path = require("path");
const { v4: uuidv4 } = require("uuid");

const port = 3001;

const app = express();

app.use(express.json());
app.set('view engine', 'pug');

app.get("/", (req, res) => {
    res.send("express webserver for spring 2025 senior project - arthur petroff")
});

app.get("/hello", (req, res) => {
    res.json({message: "Hello World"})
});

app.get("/static", (req, res) => {
    res.sendFile(path.join(__dirname, "static/express_static_page.html"))
});

app.get("/dynamic", (req, res) => {
    let headerValue = req.get("Experimental-Data");
    let randomNumber = Math.random();

    res.render(path.join(__dirname, "dynamic/express_dynamic_page.pug"), {headerValue, randomNumber});
})

app.post("/hash", async (req, res) => {
    let msg = req.body;

    let hashed_pw = await bcrypt.hash(msg.password, 8);
    let uuid = uuidv4();

    res.json({uuid: uuid, password_hash: hashed_pw});
})

app.listen(port, () => {
    console.log('Server started on port ' + port);
});