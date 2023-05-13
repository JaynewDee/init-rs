#!/bin/bash

set -e # Script will force exit when any command results in non-zero status code

if [ -z "$1" ]; then
  echo "You must pass your project's name as the first argument."
  exit
fi

project_name=$1

echo "Writing ${project_name} to $(pwd)"

cargo new $project_name
cd $project_name

cargo add actix-web

cat << EOF >> src/server.rs
use actix_web::{get, post, HttpResponse, Responder};

#[get("/")]
pub async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello world!")
}

#[post("/echo")]
pub async fn echo(req_body: String) -> impl Responder {
    HttpResponse::Ok().body(req_body)
}

pub async fn manual_hello() -> impl Responder {
    HttpResponse::Ok().body("Hey there!")
}
EOF

cat << EOF > src/main.rs
use actix_web::{web, App, HttpServer};

mod server;

use server::{hello, manual_hello, echo};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .service(hello)
            .service(echo)
            .route("/hey", web::get().to(manual_hello))
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
EOF

echo "Actix web server initialized @ $(pwd)"

cargo run

exit
