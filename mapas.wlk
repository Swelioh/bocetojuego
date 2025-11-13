import wollok.game.*
import protagonista.*
import enemigos.*
import hud.*
import controlacion.*
import menu.*

// 1. PRIMERO LAS CLASES (los "moldes")
class Nivel {
  const numero = 0
  var property position = game.at(15,18)
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
    
    if (nombreMusica != null) {
      musicaObjeto = game.sound(nombreMusica)
      musicaObjeto.shouldLoop(true) // Le decimos que se repita
      musicaObjeto.volume(0.15)
      musicaObjeto.play() // Lo reproducimos
    }
    game.schedule(3000, { => game.removeVisual(nivel) })

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
const tutorial = new TipoMapa(nivel = new Nivel(numero = 1), fondo = new FondoNivel(imagen="Summer1.png"), listaEnemigos = [maniqui], nombreMusica = "theShire.wav")
const bosque = new TipoMapa(nivel = new Nivel(numero = 2), fondo = new FondoNivel(imagen="bosques.png"), listaEnemigos = [hongo,hongoVolador,hongo2,hongo3],nombreMusica = "")
const cueva = new TipoMapa(nivel = new Nivel(numero = 3), fondo = new FondoNivel(imagen="cueva2.png"), listaEnemigos = [murcielago,golem,golem2])
const pantano = new TipoMapa(nivel = new Nivel(numero = 4), fondo = new FondoNivel(imagen="pantano2.png"), listaEnemigos = [sapo,sapo2,monstruo,monstruo2])
//const mapaFinal = new TipoMapa(nivel = new Nivel(numero = 5), fondo = new FondoNivel(imagen="finalMap.png"), listaEnemigos = [hongo])



// 3. AL FINAL DE TODO, EL OBJETO PRINCIPAL QUE USA LO ANTERIOR
object mapa {
  const niveles=[tutorial,bosque,cueva,pantano]
  var indiceNivel=0
  var nuevoMapa = tutorial
  
  method reiniciar(){
    nuevoMapa.detenerMusica()
    enemigos.reiniciarContador()
    indiceNivel=0
    nuevoMapa=niveles.get(indiceNivel)
    nuevoMapa.iniciar()
  }

  method siguienteMapa() {
    nuevoMapa.detenerMusica()
    if(indiceNivel<niveles.size()){
      nuevoMapa=niveles.get(indiceNivel)
      game.clear()
      enemigos.reiniciarContador()
      controlacion.detenerTimers()
      nuevoMapa.iniciar()
      indiceNivel += 1
    }
  }

  method mapaActual()=nuevoMapa
}