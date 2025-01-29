const express = require("express");
const bcrypt = require("bcrypt");

const port = 3001;

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
    res.json({message: "Hello World"})
});

app.post("/hash", async (req, res) => {
    let msg = req.body;
    let hashed_pw = await bcrypt.hash(msg.password, 8);

    res.json({password: hashed_pw});
})

app.listen(port, () => {
    console.log('Server started on port ' + port);
});