import enemigos.*
import protagonista.*
import direcciones.*
import hud.* // ¡Importante para actualizar su propia barra de vida!

class Inquisidor inherits EnemigoCaminador {
    
    // --- Variables de Estado del Boss ---
    var faseActual = 1
    
    // Umbrales de vida para cambiar de fase
    const vidaFase2 = vidaInicial * 0.7 
    const vidaFase3 = vidaInicial * 0.3
    
    // Timers para controlar sus acciones (para que no ataque sin parar)
    var timerAccion = 0 // Cooldown general entre acciones
    var timerAtaqueActual = 0 // Duración de un ataque (ej. estocada)
    var estaHaciendoParry = false
    
    
   override method actualizar() {
    // 1. Lógica Heredada de Golpeado (Llama a super() primero para la animación de impacto)
    super() 

    // 2. Manejo de Timer de Ataque/Parry
    if (timerAtaqueActual > 0) {
        timerAtaqueActual -= 1
        if (timerAtaqueActual == 0) {
            estaHaciendoParry = false
            image = self.reposo() 
        }
    }

    // 3. Bloque de Lógica Principal: Solo se ejecuta si el boss NO está ocupado
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
        
        if (distancia > 4) {
            // 1. Caminata Lenta: 
            // Usa la IA de 'perseguir' que heredamos,
            // pero su 'velocidadMaxima' (definida abajo) es muy baja.
            self.perseguir()
            self.aplicarFisicaHorizontal()
        } else {
            // 2. Está cerca: ¡Decide si atacar!
            estaMoviendose = false // ¡Se detiene para ser imponente!
            self.intentarEstocadaSimple()
        }
    }
    
    method intentarEstocadaSimple() {
        // (Lógica de ataque simple)
        timerAccion = 120 // 120 ticks de cooldown antes de la próxima acción
        timerAtaqueActual = 60 // El ataque dura 60 ticks
        
        // (Aquí pondrías la animación de ataque)
        // image = ...
        
        // (En el tick justo, haces el daño)
        game.schedule(1000, { => // 1 seg
             if (self.position().distance(protagonista.position()) < 5 && estaVivo) {
                // (Aquí faltaría chequear la dirección, como en protagonista.atacar)
                protagonista.restarVida(self.danioDeGolpes()) 
             }
        })
    }
    
    // --- Mecánica 3: "Parry" (¡Lo más importante!) ---
    override method recibirGolpe(danio) {
        // ¿Intento un Parry?
        // Solo en Fase 1, si no estoy atacando/parando, y tengo chance
        if (faseActual == 1 && timerAtaqueActual <= 0 && Number.randomUpTo(100) < 50) { // 50% chance
            self.ejecutarParry()
        } else {
            // Si no hago parry (o estoy en otra fase), recibo el golpe normal
            super(danio) //
            // ¡Y actualizo mi barra de vida!
            barraVidaBoss.actualizarBarra(vida)
        }
    }
    
    method ejecutarParry() {
        estaHaciendoParry = true
        timerAtaqueActual = 70 // Duración del parry + contraataque
        
        // Sonido de "Clang!"
        // game.sound("parry.wav").play()
        
        // Animación de bloqueo
        // image = "inquisidorBloqueo.png"
        
        // Prograna el contraataque
        game.schedule(500, { => // Medio seg después
            if (estaVivo) {
                // (Aquí va la lógica del contraataque rápido)
            }
        })
    }
    
    method transicionFase2() {
        faseActual = 2
        // (Aquí pondrías un rugido, un cambio de música, etc.)
    }
}

// --- Definición del Boss ---
// ¡Lo añadimos al final de enemigos.wlk o en su propio archivo!


const judgeHolden = new Inquisidor(nombre = "judgeHolden", positionInicial = game.at(30, 1),danioDeGolpes = 10, vidaInicial = 150,vida = 150,image = "golemIzquierdaQuieto.png",animMoviendose = 10,animAtaque = 11,animGolpeado = 4,sonidoGolpe = "golemHit.wav",velocidadMaxima = 0.05)
