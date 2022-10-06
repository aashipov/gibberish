use actix_web::{get, post, App, HttpResponse, HttpServer, Responder};
use uuid::Uuid;

#[get("/{tail:.*}")]
async fn get() -> impl Responder {
    HttpResponse::Ok()
        .body("Welcome to gibberish service\nHTTP POST your stuff and enjoy gibberish")
}

#[post("/{tail:.*}")]
async fn post(req_body: String) -> impl Responder {
    let mut resp = Uuid::new_v4().to_string().to_owned();
    resp.push_str(&req_body);
    resp.push_str(&Uuid::new_v4().to_string());
    HttpResponse::Ok().body(resp)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().service(get).service(post))
        .bind(("0.0.0.0", 8080))?
        .run()
        .await
}
