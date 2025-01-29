use axum::{
    body::Body, http::StatusCode, response::Response, routing::{get, post}, Json, Router
};
use serde::{Deserialize, Serialize};
use bcrypt;

#[tokio::main]
async fn main() {

    let app = Router::new()
        .route("/", get(root))
        .route("/hash", post(hash));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();

}

#[derive(Serialize, Deserialize)]
struct Message {
    message: String
}
async fn root() -> axum::Json<Message> {
    Json(Message{message: "Hello World".into()})
}

#[derive(Serialize, Deserialize)]
struct HashMessage {
    password: String
}

async fn hash(Json(posted_message): Json<HashMessage>) -> axum::Json<HashMessage> {

    let Ok(hashed_pw) = bcrypt::hash(posted_message.password, 8) else {
        return Json(HashMessage{password: "Error".into()})
    };

    Json(HashMessage{password: hashed_pw})
}