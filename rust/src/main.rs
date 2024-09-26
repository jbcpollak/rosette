use futures::prelude::*;
use zenoh::prelude::r#async::*;

#[tokio::main]
async fn main() {
    println!("Hello, world!");
    let session = zenoh::open(config::default()).res().await.unwrap();
    let subscriber = session.declare_subscriber("key/expression").res().await.unwrap();
    while let Ok(sample) = subscriber.recv_async().await {
        println!("Received: {}", sample);
    };
}
