use std::fs::File;

use axum::{
    body::Body, http::StatusCode, response::{Html, Response}, routing::{get, post}, Json, Router
};
use tower_http::services::ServeFile;
use serde::{Deserialize, Serialize};
use bcrypt;

#[tokio::main]
async fn main() {

    let app = Router::new()
    .route("/hello", get(hello_world))
    .route_service("/static", ServeFile::new("static/axum_static_page.html"))
    //.route("/dynamic", get())
    .route("/hash", post(hash))
    .route("/", get(root));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();

}

async fn root() -> String {
    "axum webserver for spring 2025 senior project - arthur petroff".into()
}
async fn hello_world() -> axum::Json<TextMessage> {
    Json(TextMessage{message: "Hello World".into()})
}
async fn hash(Json(posted_message): Json<HashMessage>) -> axum::Json<HashMessage> {
    let Ok(hashed_pw) = bcrypt::hash(posted_message.password, 8) else {
        return Json(HashMessage{password: "Error".into()})
    };
    Json(HashMessage{password: hashed_pw})
}

#[derive(Serialize, Deserialize)]
struct TextMessage {
    message: String
}
#[derive(Serialize, Deserialize)]
struct HashMessage {
    password: String
}