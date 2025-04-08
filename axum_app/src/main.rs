use std::sync::Arc;

use axum::{
    extract::State, http::{HeaderMap, StatusCode}, response::Html, routing::{get, post}, Json, Router
};
use minijinja::{context, Environment};
use serde::{Deserialize, Serialize};
use bcrypt;
use uuid::Uuid;

#[tokio::main]
async fn main() {

    let mut env = Environment::new();
    env.add_template("dynamic_page", include_str!("../dynamic/axum_dynamic_page.jinja")).unwrap();

    let state = Arc::new(env);

    let app = Router::new()
    .route("/hello", get(hello_world))
    //.route_service("/static", ServeFile::new("static/axum_static_page.html"))
    //  UNFORTUNATELY, ServeFile is rather unoptimized, making it tremendously
    //  slower than alternatives. (50+ms vs ~7ms)
    //  https://github.com/tower-rs/tower-http/issues/480
    .route("/static", get(static_file))
    .route("/dynamic", get(render_dynamic_page))
    .route("/hash", post(hash))
    .route("/", get(root))
    .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();

}

async fn root() -> String {
    "axum webserver for spring 2025 senior project - arthur petroff".into()
}
async fn hello_world() -> axum::Json<TextMessage> {
    Json(TextMessage{message: "Hello World".into()})
}
async fn static_file() -> Html<String> {
    let file = tokio::fs::read_to_string("static/axum_static_page.html").await.expect("missing static file!!");
    Html(file)
}
async fn render_dynamic_page(State(state): State<Arc<Environment<'_>>>, headers: HeaderMap) -> Result<Html<String>, StatusCode> {
    let template = state.get_template("dynamic_page").unwrap();

    let header_value = match headers.get("x-connection-id") {
        Some(val) => val.to_str().unwrap(),
        None => "0"
    };

    let rendered = template.render(context!{
        header_value
    }).unwrap();

    Ok(Html(rendered))
}
async fn hash(Json(posted_message): Json<HashRequest>) -> Json<HashResponse> {
    let Ok(hashed_pw) = bcrypt::hash(posted_message.password, 8) else {
        return Json(HashResponse{uuid: "Bcrypt Error".into(), password: "Bcrypt Error".into()})
    };
    let id = Uuid::new_v4().to_string();
    Json(HashResponse{uuid: id, password: hashed_pw})
}

#[derive(Serialize, Deserialize)]
struct TextMessage {
    message: String
}

#[derive(Serialize, Deserialize)]
struct HashRequest {
    password: String
}

#[derive(Serialize, Deserialize)]
struct HashResponse {
    uuid: String,
    password: String
}
