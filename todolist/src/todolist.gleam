import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import utils

// Main function 

pub fn main() {
  let app = lustre.application(init, update, page_view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// Models
pub type AppState {
  AppState(todos: List(Todo), input: String)
}

pub type Todo {
  Todo(id: Int, msg: String, status: TodoStatus)
}

pub type TodoStatus {
  Active
  Complete
}

// Events
pub type Msg {
  InputTask(msg: String)
  AddTodo(msg: String)
  RemoveTodo(id: Int)
  ToggleTodo(id: Int)
  None
}

// Init

pub fn init(_flags) {
  #(AppState([], ""), effect.none())
}

// Update

pub fn update(state: AppState, msg: Msg) {
  case msg {
    InputTask(text) -> #(AppState(..state, input: text), effect.none())
    AddTodo(text) ->
      case string.length(text) {
        i if i > 0 -> #(
          AppState(
            list.append(state.todos, [
              Todo(list.length(state.todos), text, Active),
            ]),
            "",
          ),
          effect.none(),
        )
        _ -> #(AppState(..state, input: text), effect.none())
      }
    RemoveTodo(id) -> #(
      AppState(
        ..state,
        todos: list.filter(state.todos, fn(elem) { elem.id != id }),
      ),
      effect.none(),
    )
    ToggleTodo(id) -> #(
      AppState(
        ..state,
        todos: list.map(state.todos, fn(elem) {
          case elem.id == id {
            True ->
              Todo(
                ..elem,
                status: case elem.status {
                  Active -> Complete
                  Complete -> Active
                },
              )
            False -> elem
          }
        }),
      ),
      effect.none(),
    )
    _ -> #(state, effect.none())
  }
}

// Views

pub fn page_view(state: AppState) {
  html.div([attribute.class("flex flex-col gap-4 max-w-xl mx-auto")], [
    input_task(state.input),
    html.hr([]),
    html.div([attribute.id("todos")], [
      html.script([attribute.src("/priv/static/main.mjs")], ""),
      ..utils.map_index(state.todos, fn(index, elem) {
        list_item_view(index, elem)
      })
    ]),
  ])
}

pub fn input_task(val: String) {
  html.div([attribute.class("flex gap-2 px-2 pt-8")], [
    html.input([
      attribute.class("input input-bordered w-full "),
      attribute.placeholder("Enter new task"),
      attribute.type_("text"),
      attribute.value(val),
      event.on_input(InputTask),
    ]),
    html.button(
      [attribute.class("btn btn-outline"), event.on_click(AddTodo(val))],
      [html.text("Add")],
    ),
  ])
}

pub fn list_item_view(id: Int, task: Todo) {
  html.div(
    [
      attribute.class(
        "flex gap-4 px-4 py-2 border rounded-lg items-center justify-between",
      ),
      case task.status {
        Active -> attribute.class("")
        Complete -> attribute.class("line-through")
      },
      event.on_click(ToggleTodo(id)),
    ],
    [
      html.span([], [element.text(task.msg)]),
      html.button(
        [
          attribute.class("btn btn-warning btn-square"),
          event.on_click(RemoveTodo(id)),
        ],
        [
          html.span([attribute.class("material-symbols-outlined")], [
            element.text("delete"),
          ]),
        ],
      ),
    ],
  )
}
