import creditos.*
import reglamento.*
import juego.*
import wollok.game.*
import mapas.*
import protagonista.*
import enemigos.*
import controlacion.*
import hud.*

object menu {
  const ancho = 56
  const alto = 25
  var reinicio = false
  var listenerAgregado = false
  var opcionSeleccionada = 1
  const botones = [botonJugar, botonInstrucciones, botonCreditos]

  method iniciarJuego(){
    game.clear()
    game.height(alto)
    game.width(ancho)
    self.iniciarMenu()
  }

  method reiniciar() {
    reinicio = true
    listenerAgregado = false
    self.iniciarMenu()
  }

  method actualizarMenuVisual() {
    botones.forEach({ boton =>
      boton.actualizarVisual(opcionSeleccionada)
    })
  }


  method iniciarMenu(){
    if (reinicio){
      game.clear()
    }
    game.addVisual(fondoMenu)
    game.addVisual(botonJugar)
    game.addVisual(botonInstrucciones)
    game.addVisual(botonCreditos)

    if (not listenerAgregado) {
      listenerAgregado = true
      keyboard.num(1).onPressDo {
          opcionSeleccionada = 1
          self.actualizarMenuVisual() // Actualiza todas las imágenes
      }

      keyboard.num(2).onPressDo {
          opcionSeleccionada = 2
          self.actualizarMenuVisual()
      }

      keyboard.num(3).onPressDo {
          opcionSeleccionada = 3
          self.actualizarMenuVisual()
      }
      keyboard.enter().onPressDo{
        self.ejecutarOpcion(opcionSeleccionada)
        listenerAgregado = false
      }
     
    }
  }

method ejecutarOpcion(opcion) {
    self.cerrarMenu() // Cierra el menú en cualquier caso

    if (opcion == 1) {

        mapa.siguienteMapa()
        //controlacion.configuracionControles()
     
    }
    else if (opcion == 2) {
     
      fondoInstrucciones.mostrar()
    }
  else if (opcion == 3) {
    // 3. CREDITOS
    credito.visualizar()
    }
  }
  method cerrarMenu() {
    game.removeVisual(fondoMenu)
    game.removeVisual(botonJugar)
    game.removeVisual(botonInstrucciones)
    game.removeVisual(botonCreditos)
  }

}




object finDelJuego {
    method position() = game.at(10, 8)
    method image() = "fin.png"

    // Marca si ya se agregó el listener
    var property listenerAgregado = false

    // Método para agregar el listener solo una vez
    method agregarListener() {
        if (not listenerAgregado) {
            listenerAgregado = true
            keyboard.r().onPressDo({
                =>
                controlacion.detenerTimers()
                game.clear()
                mapa.reiniciar()
                listenerAgregado = false
            })
        }
    }
}

object fondoMenu {
    method position() = game.at(0,0)
    method image() = "fondoMenu2.png"
}


class BotonMenu {
    // Propiedades que se definen al crear el botón
    var property position
    const miOpcion // El número de este botón (1, 2, o 3)
    const imagenIluminada
    const imagenOscura


    var property image 

// Método clave: el botón decide qué imagen mostrar
    method actualizarVisual(opcionActual) {
        if (opcionActual == miOpcion) {
           image = imagenIluminada
        } else {
            image = imagenOscura
          }
    }
}

// 2. CREAMOS LOS BOTONES USANDO LA CLASE
const botonJugar = new BotonMenu(
    position = game.at(38, 20), // Posición del viejo 'instrucciones'
    miOpcion = 1,
    imagenIluminada = "inicio.png",
    imagenOscura = "inicioOscuro.png", // La imagen oscura
    image = "inicio.png" // Estado inicial (iluminado)
)

const botonInstrucciones = new BotonMenu(
    position = game.at(37, 17), // Posición del viejo 'manejoJuego'
    miOpcion = 2,
    imagenIluminada = "reglamento.png",
    imagenOscura = "reglamentoOscuro.png",
    image = "reglamentoOscuro.png" // Estado inicial (oscuro)
)

const botonCreditos = new BotonMenu(
    position = game.at(38, 14), // Posición del viejo 'creditos'
    miOpcion = 3,
    imagenIluminada = "creditos.png",
    imagenOscura = "creditosOscuro.png",
    image = "creditosOscuro.png" // Estado inicial (oscuro)
)