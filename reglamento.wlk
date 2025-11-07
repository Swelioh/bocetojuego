import wollok.game.*
import menu.*

object fondoInstrucciones {
  
  method mostrar() {
    game.clear()
    game.addVisual(fondoInstruccion)


    keyboard.z().onPressDo{
        menu.reiniciar()
    }

  }
}

object fondoInstruccion {
    method position()= game.at(0,0)
    method image() = "instrucciones1.png"
}
