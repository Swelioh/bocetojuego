import wollok.game.*
import menu.*

object credito {

  method visualizar() {
    game.clear()
    game.addVisual(fondoCredito)


    keyboard.z().onPressDo{
        menu.reiniciar()
    }

  }
}

object fondoCredito {
    method position()= game.at(20,4)
    method image() = "fondocredito.png"
}