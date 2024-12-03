import gleam/dynamic
import gleam/int
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

pub type Model {
  Model(counter: Int, joke: String)
}

pub type Msg {
  Inc
  Rst
  GetJoke(Result(String, lustre_http.HttpError))
}

fn init(_flags) {
  #(Model(0, ""), effect.none())
}

fn update(model: Model, msg: Msg) {
  case msg {
    Inc -> #(Model(..model, counter: model.counter + 1), get_fact())
    Rst -> #(Model(0, ""), effect.none())
    GetJoke(Ok(joke)) -> #(Model(..model, joke: joke), effect.none())
    GetJoke(Error(_)) -> #(model, effect.none())
  }
}

fn view(model: Model) {
  let count = int.to_string(model.counter)

  html.div([attribute.class("flex flex-col gap-4 items-center")], [
    html.h1([attribute.class("text-5xl font-medium")], [
      element.text("Press the cat!"),
    ]),
    html.figure([], [
      html.img([
        attribute.src(
          "https://images.unsplash.com/photo-1516280030429-27679b3dc9cf?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        ),
        event.on_click(Inc),
      ]),
      html.figcaption([attribute.class("text-center text-xl")], [
        element.text("cat clicked " <> count <> " times!"),
      ]),
    ]),
    html.button([event.on_click(Rst)], [element.text("reset counter")]),
    html.p([attribute.class("px-8 text-center")], [element.text(model.joke)]),
  ])
}

fn get_fact() {
  let decode =
    dynamic.decode2(
      fn(tp: String, pn: String) { tp <> " " <> pn },
      dynamic.field("setup", dynamic.string),
      dynamic.field("punchline", dynamic.string),
    )
  let expect = lustre_http.expect_json(decode, GetJoke)

  lustre_http.get("https://official-joke-api.appspot.com/jokes/random", expect)
}
