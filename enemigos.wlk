import controlacion.*
import wollok.game.*
import mapas.*
import protagonista.*
import direcciones.*
import proyectil.*

object enemigos {
  // Este contador ahora es para los enemigos derrotados EN EL MAPA ACTUAL
  var property contador = 0
  
  method contadorEnemigos() = contador

  
  method registrarMuerte(enemigo) {
    const mapaActual = mapa.mapaActual()
    var cambioDeMapa = false
    // Si estamos en el tutorial, solo avanzamos si muere el maniqui
    if (mapaActual == tutorial) {
        if (enemigo == maniqui) {
            contador = 1 
            mapa.siguienteMapa()
            cambioDeMapa = true
        }
   
    } else if (mapaActual == cueva) {
        contador += 1
        if (contador >= 3) {
            mapa.siguienteMapa()
            cambioDeMapa = true
        }
    }else {
        contador += 1
        if (contador >= 4) {
            mapa.siguienteMapa()
            cambioDeMapa = true
        }
     
    }
    return cambioDeMapa
  }

  // Agregamos un método para reiniciar el contador
  method reiniciarContador() {
    contador = 0
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
    

    var property frameActual = 0
    var property estaMoviendose = false
    var property estaAtacando = false
    var property timerAtaque = 0
    const property duracionAtaque = 25
    var property soloDaniaAlAtacar = false


    var property velocidadX = 0
    var property aceleracion = 0.05
    var property friccion = 0.03
    var property velocidadMaxima = 0.1
    const property rangoDeAtaque = 1

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

    method atacando() {
        return direccionHorizontal.animacionAtacando(self.nombre(), animAtaque)
    }

     method reiniciar() {
        estaVivo = true
        vida = vidaInicial
        position = positionInicial
        timerImpacto = 0
        frameActual = 0
        estaMoviendose = false
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

    
        const cambioDeMapa = enemigos.registrarMuerte(self) 
        mapa.mapaActual().listaEnemigos().remove(self)
     

    
        game.removeVisual(self)
      
        if (not cambioDeMapa) {
            
            mapa.mapaActual().agregarEnemigos()
        }
        game.removeVisual(self)
    }

   method actualizar() {
        if (timerImpacto > 0) {
            // --- Lógica de GOLPEADO ---
            timerImpacto -= 1
            const animacion = self.golpeado()

            const ticksPorFrame = (duracionImpacto / self.golpeado().size()).max(1) // Evita división por cero
            const tiempoPasado = duracionImpacto - timerImpacto
            var frameIndex = (tiempoPasado / ticksPorFrame).floor()
            frameIndex = frameIndex.min(self.golpeado().size() - 1)

            image = self.golpeado().get(frameIndex)

            if (timerImpacto == 0 && estaVivo) {
                image = self.reposo()
            }
            // --- FIN Lógica de GOLPEADO ---

        } 
        else if (estaAtacando) {
            // --- Lógica de ATACANDO ---
            const animacion = self.atacando()
            
            const ticksPorFrame = (duracionAtaque / animacion.size()).max(1)
            const tiempoPasado = duracionAtaque - timerAtaque
            var frameIndex = (tiempoPasado / ticksPorFrame).floor()
            frameIndex = frameIndex.min(animacion.size() - 1)
            
            image = animacion.get(frameIndex)

            timerAtaque -= 1
            if (timerAtaque <= 0) {
                estaAtacando = false
                if (estaVivo) { // Volver al reposo si no murió
                    image = self.reposo()
                }
            }
            // --- FIN Lógica de ATACANDO ---

        } else if (estaVivo) { 
            // --- Lógica de REPOSO ---
            // Si no está golpeado NI atacando, muestra la imagen de reposo
            // (La subclase se encargará de cambiar esto si se está moviendo)
            image = self.reposo()
        }
    }
}

class EnemigoCaminador inherits Enemigo(soloDaniaAlAtacar=true,rangoDeAtaque = 3) {
    var property radioDeAgresion = 10
    

    method perseguir() {
        const posProtagonista = protagonista.position()
        const distanciaAlProta = self.position().distance(posProtagonista)
        const distanciaAtaque = 1.5

       if (distanciaAlProta <= distanciaAtaque && not estaAtacando) {
            estaMoviendose = false
            velocidadX = 0
            
            // Iniciar el estado de ataque
            estaAtacando = true
            timerAtaque = duracionAtaque
        }else if (distanciaAlProta <= radioDeAgresion && not estaAtacando) {
          if (posProtagonista.x() > position.x() + 0.1) {
                velocidadX += aceleracion
                estaMoviendose = true
                direccionHorizontal = derecha 
             } else if (posProtagonista.x() < position.x() - 0.1) {
                velocidadX -= aceleracion
                estaMoviendose = true
                direccionHorizontal = izquierda 
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
        if (timerImpacto <= 0 && estaVivo && not estaAtacando) {

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
    var property imagenProyectil = "proyectil.png"

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
            proyectilPropio = new Proyectil(posX = self.position().x(), posY = self.position().y(), danio = danioProyectil,image = self.imagenProyectil())
            proyectilPropio.spawnear()
        } 
    }

    override method morir() {

        if (proyectilPropio != null) {
            game.removeVisual(proyectilPropio)
            proyectilActivo = false
            proyectilPropio = null
        }
        super() 
    }

    method aplicarFisicaHorizontal() {
        if (position.x() > bordeDerecho) {
            velocidadX = 0.2
            direccionHorizontal = izquierda
        } else if (position.x() < bordeIzquierdo) {
            velocidadX = -0.2
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

const maniqui = new Enemigo(nombre = "maniqui",vidaInicial = 100,vida = 100,danioDeGolpes = 0,image = "maniquiIzquierdaQuieto.png",animGolpeado = 3,sonidoGolpe = "golpemaniqui.wav",positionInicial = game.at(40, 1))

const hongo = new EnemigoCaminador(nombre = "mushRoom", danioDeGolpes = 20, vidaInicial = 75,vida = 75,image = "mushRoomIzquierdaQuieto.png",animMoviendose = 8,animAtaque = 10,animGolpeado = 5,sonidoGolpe = "mushroomHit.wav",positionInicial = game.at(20, 1))
const hongo2 = new EnemigoCaminador(nombre = "mushRoom", danioDeGolpes = 20, vidaInicial = 75,vida = 75,image = "mushRoomIzquierdaQuieto.png",animMoviendose = 8,animAtaque = 10,animGolpeado = 5,sonidoGolpe = "mushroomHit.wav",positionInicial = game.at(30, 1))
const hongo3 = new EnemigoCaminador(nombre = "mushRoom", danioDeGolpes = 20, vidaInicial = 75,vida = 75,image = "mushRoomIzquierdaQuieto.png",animMoviendose = 8,animAtaque = 10,animGolpeado = 5,sonidoGolpe = "mushroomHit.wav",positionInicial = game.at(40, 1))


const murcielago = new EnemigoVolador(nombre = "bat", danioDeGolpes = 15, danioProyectil = 10, vidaInicial = 50,image = "batIzquierdaQuieto.png", velocidadX = 0.5, animMoviendose = 4,animGolpeado = 3,sonidoGolpe = "batHit.wav",positionInicial = game.at(15, 11),imagenProyectil = "proyectil_murcielago.png" )

const hongoVolador = new EnemigoVolador(nombre = "hongoVolador", danioDeGolpes = 15, danioProyectil = 10, vidaInicial = 50,image = "hongoVoladorIzquierdaMoviendose1.png", velocidadX = 0.2, animMoviendose = 8,animGolpeado = 4,sonidoGolpe = "mushroomHit.wav",positionInicial = game.at(15, 12),imagenProyectil = "proyectil_hongoVolador.png" )

const golem = new EnemigoCaminador(nombre = "golem", danioDeGolpes = 10, vidaInicial = 150,vida = 150,image = "golemIzquierdaQuieto.png",animMoviendose = 10,animAtaque = 11,animGolpeado = 4,sonidoGolpe = "golemHit.wav",positionInicial = game.at(30, 1))
const golem2 = new EnemigoCaminador(nombre = "golem", danioDeGolpes = 10, vidaInicial = 150,vida = 150,image = "golemIzquierdaQuieto.png",animMoviendose = 10,animAtaque = 11,animGolpeado = 4,sonidoGolpe = "golemHit.wav",positionInicial = game.at(45, 1))

const sapo = new EnemigoCaminador(nombre = "sapo", danioDeGolpes = 20, vidaInicial = 100,vida = 100,image = "sapoIzquierdaQuieto.png",animMoviendose = 7,animAtaque = 8,animGolpeado = 4,sonidoGolpe = "sapoHit.wav",positionInicial = game.at(30, 1))
const sapo2 = new EnemigoCaminador(nombre = "sapo", danioDeGolpes = 20, vidaInicial = 100,vida = 100,image = "sapoIzquierdaQuieto.png",animMoviendose = 7,animAtaque = 8,animGolpeado = 4,sonidoGolpe = "sapoHit.wav",positionInicial = game.at(45, 1))

const monstruo = new EnemigoVolador(nombre = "monstruo", danioDeGolpes = 15, danioProyectil = 10, vidaInicial = 50,image = "monstruoIzquierdaMoviendose1.png", velocidadX = 0.2, animMoviendose = 5,animGolpeado = 4,sonidoGolpe = "mushroomHit.wav",positionInicial = game.at(15, 11),imagenProyectil = "proyectil_hongoVolador.png" )
const monstruo2 = new EnemigoVolador(nombre = "monstruo", danioDeGolpes = 15, danioProyectil = 10, vidaInicial = 50,image = "monstruoIzquierdaMoviendose1.png", velocidadX = 0.2, animMoviendose = 5,animGolpeado = 4,sonidoGolpe = "mushroomHit.wav",positionInicial = game.at(15, 11),imagenProyectil = "proyectil_hongoVolador.png" )



