import wollok.game.*
import menu.*

object fondoInstrucciones {
  
  method mostrar() {
    game.clear()
    game.addVisual(fondoInstruccion)
    game.addVisual(reglas)  
    game.addVisual(ataque)
    game.addVisual(escudo)
    game.addVisual(movimientos)


    keyboard.z().onPressDo{
        menu.reiniciar()
    }

  }
}

object fondoInstruccion {
    method position()= game.at(0,0)
    method image() = "instrucciones.png"
}
object reglas {
    method position()= game.at(4,18)
    method image() = "tecladomac.png"
}
object ataque {
    method position()= game.at(4,16)
    method image() = "golpear.png"
}
object escudo {
    method position()= game.at(4,15)
    method image() = "escudo.png"
}
object movimientos {
    method position()= game.at(4,14)
    method image() = "movimiento.png"
}
