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
    method position()= game.at(0,0)
    method image() = "fondoCreditos.png"
}