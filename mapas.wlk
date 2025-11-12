import wollok.game.*
import protagonista.*
import enemigos.*
import hud.*
import controlacion.*
import menu.*

// 1. PRIMERO LAS CLASES (los "moldes")
class Nivel {
  const numero = 0
  var property position = game.at(20,15)
  method image() = "nivel" + numero + ".png"
}

class TipoMapa {
  const nivel = new Nivel(numero = 0)
  const fondo = FondoNivel
  const listaEnemigos = []
  const enemigos = []
  const listaEnemigosEnPantalla = []
  const nombreMusica = null
  var musicaObjeto = null

  method iniciar() {
    listaEnemigos.forEach({enemigo => enemigo.reiniciar()})
    enemigos.clear()                         // Vacía la lista actual
    enemigos.addAll(listaEnemigos)
    game.addVisual(fondo)
    game.addVisual(nivel)
    self.agregarEnemigos()
    self.agregarEnemigos()
    self.agregarEnemigos()
    if (nombreMusica != null) {
      musicaObjeto = game.sound(nombreMusica)
      musicaObjeto.shouldLoop(true) // Le decimos que se repita
      musicaObjeto.volume(0.15)
      musicaObjeto.play() // Lo reproducimos
    }
    game.schedule(5000, { => game.removeVisual(nivel) })

    game.addVisual(barraDeVida)     
    game.addVisual(barraDeEnergia)
    game.addVisual(protagonista)
    protagonista.iniciar()
    controlacion.configuracionControles()
  }

  method detenerMusica() {
    if (musicaObjeto != null) {
      musicaObjeto.stop()
      musicaObjeto = null // Limpiamos la referencia
    }
  }

  method agregarEnemigos(){
    if(enemigos.size() > 0){
      const nuevoEnemigo = enemigos.first()
      listaEnemigosEnPantalla.add(nuevoEnemigo)
      game.addVisual(nuevoEnemigo)
      enemigos.remove(nuevoEnemigo)
    }
  }

  method listaEnemigos() = listaEnemigosEnPantalla
}
class FondoNivel{
  var property position = game.at(0,0)
  const imagen="bosque.png"
  method image()=imagen
}

// 2. LUEGO LAS CONSTANTES (los "objetos" creados a partir de los moldes)
const tutorial = new TipoMapa(nivel = new Nivel(numero = 1), fondo = new FondoNivel(imagen="Summer1.png"), listaEnemigos = [maniqui, hongo, murcielago, hongo2], nombreMusica = "theShire.wav")
const bosque = new TipoMapa(nivel = new Nivel(numero = 2), fondo = new FondoNivel(imagen="bosque1.png"), listaEnemigos = [hongo,murcielago],nombreMusica = "")
const agua = new TipoMapa(nivel = new Nivel(numero = 3), fondo = new FondoNivel(imagen="aguas.png"), listaEnemigos = [hongo])
const nevado = new TipoMapa(nivel = new Nivel(numero = 4), fondo = new FondoNivel(imagen="nevada.png"), listaEnemigos = [hongo])
const mapaFinal = new TipoMapa(nivel = new Nivel(numero = 5), fondo = new FondoNivel(imagen="finalMap.png"), listaEnemigos = [hongo])



// 3. AL FINAL DE TODO, EL OBJETO PRINCIPAL QUE USA LO ANTERIOR
object mapa {
  const niveles=[tutorial,bosque,nevado,agua,mapaFinal]
  var indiceNivel=0
  var nuevoMapa = tutorial
  
  method reiniciar(){
    nuevoMapa.detenerMusica()
    indiceNivel=0
    nuevoMapa=niveles.get(indiceNivel)
    nuevoMapa.iniciar()
  }

  method siguienteMapa() {
    nuevoMapa.detenerMusica()
    if(indiceNivel<niveles.size()){
      nuevoMapa=niveles.get(indiceNivel)
      game.clear()
      controlacion.detenerTimers()
      nuevoMapa.iniciar()
      indiceNivel =+ 1
    }
  }

  method mapaActual()=nuevoMapa
}