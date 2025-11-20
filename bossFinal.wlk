import enemigos.*
import protagonista.*
import direcciones.*
import hud.* // ¡Importante para actualizar su propia barra de vida!

class Inquisidor inherits EnemigoCaminador {
    
    // --- Variables de Estado del Boss ---
    var faseActual = 1

    //  vida para cambiar de fase
    const vidaFase2 = vidaInicial * 0.7 
    const vidaFase3 = vidaInicial * 0.3
    
    // Timers para controlar sus acciones (para que no ataque sin parar)
    var timerAccion = 0 // Cooldown general entre acciones
    var timerAtaqueActual = 0 // Duración de un ataque 
    var estaHaciendoParry = false
    
    method animacionEstocada() {
    return direccionHorizontal.animacionAtacando("inquisidor", 6)
}
    
   override method actualizar() {
    //  Lógica Heredada de Golpeado (Llama a super() primero para la animación de impacto)
    super() 

    //  Manejo de Timer de Ataque/Parry
    if (timerAtaqueActual > 0) {
        timerAtaqueActual -= 1
        const animacion = self.animacionEstocada()
        const duracionTotal = 25 // El valor original de timerAtaqueActual
        
        // (60 ticks / 6 frames = 10 ticks por frame)
        const ticksPorFrame = duracionTotal / animacion.size() 
        
        const tiempoPasado = duracionTotal - timerAtaqueActual
        var frameIndex = (tiempoPasado / ticksPorFrame).floor()
        frameIndex = frameIndex.min(animacion.size() - 1) // Seguridad
        
        image = animacion.get(frameIndex)
        if (timerAtaqueActual == 0) {
            estaHaciendoParry = false
            image = self.reposo() 
        }
    }

    //  Bloque de Lógica Principal: Solo se ejecuta si el boss NO está ocupado
    // El boss está ocupado si: a) acaba de ser golpeado (timerImpacto > 0) O b) está atacando/en parry (timerAtaqueActual > 0).
    if (timerImpacto <= 0 && timerAtaqueActual <= 0) {
        
        // 3a. Chequeo de Transición de Fase
        if (faseActual == 1 && vida <= vidaFase2) {
            self.transicionFase2()
        }
        
        // 3b. Cooldown general (para que no ataque en cada tick)
        if (timerAccion > 0) {
            timerAccion -= 1
        } else {
            // 3c. Lógica de IA - Fase 1
            self.comportamientoFase1()
        }
    }
    // El método termina aquí de forma natural, sin el conflictivo 'return'.
}

   
    // --- IA de la FASE 1 ---
    method comportamientoFase1() {
        const distancia = self.position().distance(protagonista.position())
        
        if (distancia > 10) {
        
        
            
            self.perseguir()
            self.aplicarFisicaHorizontal()
        } else {
            //  Está cerca: Decide si atacar
            estaMoviendose = false // Se detiene 
            self.intentarEstocadaSimple()
        }
    }
    
    method intentarEstocadaSimple() {
        // (Lógica de ataque simple)
        timerAccion = 85 // 120 ticks de cooldown antes de la próxima acción
        timerAtaqueActual = 25// El ataque dura 60 ticks
        

        
        // (En el tick justo, haces el daño)
        game.schedule(1150, { => // 1 seg
             if (self.position().distance(protagonista.position()) < 12 && estaVivo) {
                // (Aquí faltaría chequear la dirección, como en protagonista.atacar)
                protagonista.recibirGolpe(self.danioDeGolpes(), self)
             }
        })
    }
    
    // --- Mecánica 3: "Parry" (¡Lo más importante!) ---
    override method recibirGolpe(danio) {
        // ¿Intento un Parry?
        // Solo en Fase 1, si no estoy atacando/parando, y tengo chance
        if (faseActual == 2 && timerAtaqueActual <= 0  ) { // 50% chance esto va adentro && Number.randomUpTo(100) < 50
            self.ejecutarParry()
        } else {
            // Si no hago parry (o estoy en otra fase), recibo el golpe normal
            super(danio) //
            //  actualizo barra de vida
            barraVidaBoss.actualizarBarra(vida)
        }
    }
    
    method ejecutarParry() {
        estaHaciendoParry = true
        timerAtaqueActual = 70 // Duración del parry + contraataque
        
        
        // game.sound("parry.wav").play()
        
        // Animación de bloqueo
        // image = "inquisidorBloqueo.png"
        
        //  el contraataque
        game.schedule(500, { => // Medio seg después
            if (estaVivo) {
                // falta
            }
        })
    }
    
    method transicionFase2() {
        faseActual = 2
        // (Aquí pondrías un rugido, un cambio de música, etc.)
    }
}

// --- Definición del Boss ---
//


const inquisidor = new Inquisidor(nombre = "inquisidor", positionInicial = game.at(30, 1),danioDeGolpes = 25, vidaInicial = 300,vida = 300,image = "inquisidorIzquierdaQuieto.png",animMoviendose = 8,animAtaque = 11,animGolpeado = 4,sonidoGolpe = "golemHit.wav",velocidadMaxima = 0.05,radioDeAgresion=20)


