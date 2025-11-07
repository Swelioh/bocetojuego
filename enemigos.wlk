import controlacion.*
import wollok.game.*
import mapas.*
import protagonista.*
import direcciones.*
import proyectil.*

object enemigos {
  var contador = 0
  method contadorEnemigos() = contador
  method incrementarContador() {
    contador += 1
    if(contador>10){
        mapa.siguienteMapa()  
    }
  }
  method disminuirContador() {
    contador -= 1
  }
}
class Enemigo{
    var property nombre = ""
    var property position = game.at(40, 1)
    var property danioDeGolpes = 10
    var property vida = 70
    var property estaVivo = true
    var property direccionHorizontal = izquierda
    var property image = "error.png" // El hijo lo define al crearse

    var property animReposo = 0 // (no se usa, es 1 imagen)
    var property animMoviendose = 1
    var property animGolpeado = 1
    var property animAtaque = 1

    var frameActual = 0
    var estaMoviendose = false

    var property velocidadX = 0
    var property aceleracion = 0.05
    var property friccion = 0.03
    var property velocidadMaxima = 0.1

    //----VARIABLES DE SONIDO---
    const sonidoGolpe = null

    //----VARIABLES DE REINICIO
    const property positionInicial
    const property vidaInicial

    method direccionH() = direccionHorizontal

    method reposo(){
        return direccionHorizontal.imagenReposo(self.nombre())
    }
    method golpeado() {
        return direccionHorizontal.animacionGolpeado(self.nombre(), animGolpeado)
    }
    method moviendose() {
        return direccionHorizontal.animacionMoviendose(self.nombre(), animMoviendose)
    }
    method derrotado() {
        return direccionHorizontal.imagenDerrotado(self.nombre())
    }

    method reiniciar() {
        estaVivo = true
        vida = vidaInicial
        position = positionInicial
        timerImpacto = 0
        frameActual = 0
        estaMoviendose = false
        velocidadX = 0
        // (Añadimos esto para el murciélago)
        if (nombre == "bat") { velocidadX = 0.5 } 
        image = self.reposo()
    }

    var timerImpacto = 0
    const duracionImpacto = 15

    
    method vida() = vida
    method danioDeGolpes() = danioDeGolpes

    method recibirGolpe(danio) {
        //game.sound(sonidoGolpe).play()
        if (estaVivo) {
            vida -= danio
            timerImpacto = duracionImpacto

              if (sonidoGolpe != null) {
                 game.sound(sonidoGolpe).play()
            }

            if (vida <= 0) {
                vida = 0
                self.morir()
            }
        }
    }

    method morir() {
        estaVivo = false
        image = self.derrotado()
        enemigos.incrementarContador()
        //mapa.mapaActual().agregarEnemigos()
        position = game.at(-999, -999)
        //game.removeVisual(self)
    }

    method actualizar() {
        if (timerImpacto > 0) {
            timerImpacto -= 1

            const animacion = self.golpeado()

            const ticksPorFrame = duracionImpacto / self.golpeado().size()
            const tiempoPasado = duracionImpacto - timerImpacto
            var frameIndex = (tiempoPasado / ticksPorFrame).floor()
            frameIndex = frameIndex.min(self.golpeado().size() - 1)

            image = self.golpeado().get(frameIndex)

            if (timerImpacto == 0 && estaVivo) {
                image = self.reposo()
            }
        }else if (estaVivo) { 
            // Si no está golpeado, muestra la imagen de reposo
            image = self.reposo()
        }
    }
}

class EnemigoCaminador inherits Enemigo {
    var property radioDeAgresion = 10

    method perseguir() {
        const posProtagonista = protagonista.position()
        const distanciaAlProta = self.position().distance(posProtagonista)

        if (distanciaAlProta <= radioDeAgresion) {
          if (posProtagonista.x() > position.x() + 0.1) {
                velocidadX += aceleracion
                estaMoviendose = true
                direccionHorizontal = derecha // <-- CAMBIO
             } else if (posProtagonista.x() < position.x() - 0.1) {
                velocidadX -= aceleracion
                estaMoviendose = true
                direccionHorizontal = izquierda // <-- CAMBIO 
             } else {
                estaMoviendose = false
             }
        } else {
            estaMoviendose = false
        }
    }

    method aplicarFisicaHorizontal() {
        if (velocidadX > velocidadMaxima) {
            velocidadX = velocidadMaxima
        } else if (velocidadX < -velocidadMaxima) {
            velocidadX = -velocidadMaxima
        }
        position = position.right(velocidadX)
        if (not estaMoviendose) {
            if (velocidadX > 0) {
                velocidadX -= friccion
                if (velocidadX < 0) velocidadX = 0 
            } else if (velocidadX < 0) {
                velocidadX += friccion
                if (velocidadX > 0) velocidadX = 0
            }
        }
   }

    override method actualizar() {
        super()
        if (timerImpacto <= 0 && estaVivo) {

            self.perseguir()
            self.aplicarFisicaHorizontal()

            if (estaMoviendose) {
                const animacion = self.moviendose()
                if (animacion.size() > 0) {
                    const frameIndex = frameActual % animacion.size()
                    image = animacion.get(frameIndex)

                    frameActual += 1
                }
            } 

        }
    }
}

class EnemigoVolador inherits Enemigo {
    const bordeIzquierdo = 2
    const bordeDerecho = 55
    var proyectilActivo = false
    var proyectilPropio = null
    const danioProyectil = 0

    method actualizarProyectil() {
        const posProtagonista = protagonista.position()
        const distancia = (self.position().x() - posProtagonista.x()).abs()

        if (proyectilActivo && proyectilPropio != null) {
            proyectilPropio.actualizar(self)

            // Si el proyectil se destruyó o salió de pantalla:
            if (proyectilPropio.estaFueraDePantalla()) {
                game.removeVisual(proyectilPropio)
                proyectilActivo = false
                proyectilPropio = null
            }

        } else if (distancia < 3) {
            proyectilActivo = true
            proyectilPropio = new Proyectil(posX = self.position().x(), posY = self.position().y(), danio = danioProyectil)
            proyectilPropio.spawnear()
        } 
    }

    method aplicarFisicaHorizontal() {
        if (position.x() > bordeDerecho) {
            velocidadX = 0.5
            direccionHorizontal = izquierda
        } else if (position.x() < bordeIzquierdo) {
            velocidadX = -0.5
            direccionHorizontal = derecha
        }
        position = position.left(velocidadX)
    }
    
    override method actualizar() {
        super()
        if (timerImpacto <= 0 && estaVivo) {
            self.aplicarFisicaHorizontal()
            self.actualizarProyectil()

            const animacion = self.moviendose()
            if (animacion.size() > 0) {
                const frameIndex = frameActual % animacion.size()
                image = animacion.get(frameIndex)

                frameActual += 1
            } 
        }
    }
}

const maniqui = new Enemigo(nombre = "maniqui",vidaInicial = 9999,vida = 9999,danioDeGolpes = 0,image = "maniquiIzquierdaQuieto.png",animGolpeado = 3,sonidoGolpe = "golpemaniqui.wav",positionInicial = game.at(40, 1))

const hongo = new EnemigoCaminador(nombre = "mushRoom",position = game.at(20, 1), danioDeGolpes = 50, vida = 10,vidaInicial = 10,image = "mushRoomIzquierdaQuieto.png",animMoviendose = 8,animGolpeado = 5,sonidoGolpe = "mushroomHit.wav",positionInicial = game.at(20, 1))

const murcielago = new EnemigoVolador(nombre = "bat",position = game.at(5, 20), danioDeGolpes = 15, danioProyectil = 10, vida = 50,vidaInicial = 50,image = "batIzquierdaQuieto.png", velocidadX = 0.5, animMoviendose = 5,animGolpeado = 3,sonidoGolpe = "batHit.wav",positionInicial = game.at(5, 20) )
