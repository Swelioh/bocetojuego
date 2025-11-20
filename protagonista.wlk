import mapas.*
import enemigos.*
import menu.*
import direcciones.*
import hud.*
import wollok.game.*
object protagonista {

//-------VARIABLES DE MOVIMIENTO-----------
  const fuerzaSalto = 1.8 // Impulso inicial hacia arriba.
  const gravedad = -0.2 // Fuerza que tira hacia abajo en cada tick.
  var velocidadVertical = 0 // Positiva es subiendo, negativa es bajando.
  var movimientoHorizontal = false // Variable de estado para el movimiento.
  var property position= game.at(0, 1)
  var velocidadX = 0
  const friccion = 0.1
//-------VARIABLES DE ATAQUE-----------
  var estaAtacando = false      
  var timerAtaque = 0          
  const duracionAtaque = 12

//------VARIABLES DE VIDA
  var property personajeVida = 100
  var property estaVivo = true

  method personajeVida() = personajeVida

  // ------VARIABLES DE DAÑO Y EMPUJE 
    var timerInvencible = 0
    const duracionInvencible = 30 // Ticks de invencibilidad (aprox 1.5 seg)
    const fuerzaEmpujeVertical = 1  // Salto al ser golpeado (ajustable)
    const fuerzaEmpujeHorizontal = 4 // Empuje horizontal (ajustable)
 

// --- VARIABLES DE ESCUDO (ENERGÍA) ---
	var estaBloqueando = false
	var energiaEscudo = 100
	const maxEnergiaEscudo = 100
	const reduccionDeDanio = 0.75 // Bloquea el 75% del daño
	const umbralActivarEscudo = 10 // Energía mínima para poder levantar el escudo
	const costeMantenerEscudo = 0.5 // Costo por tick por mantenerlo
	const costeGolpeEscudo = 15 // Costo extra al recibir un golpe
	const recargaEnergia = 0.3 // Regeneración por tick cuando no se usa

    // --- VARIABLES DE DASH (ENERGÍA) ---
    var estaHaciendoDash = false
    var timerDash = 0
    var invenciblePorDash = false   

    // --- PROPIEDADES PARA ANIMACIÓN ---
  var property image = "guerrero1Derecha.png"
  var direccionHorizontal = derecha
  var frameActual = 0 // Un contador para ciclar las imágenes.

  //------ASSETS DE ANIMACION
    method obtenerAnimacionCaminar() {
        return direccionHorizontal.animacionMoviendose("guerrero", 3)
    }

    method obtenerImagenSalto() {
        return direccionHorizontal.imagenSalto("guerrero")
    }

    method obtenerAnimacionAtaque() {
        return direccionHorizontal.animacionAtacando("guerrero", 5)
    }

    method obtenerImagenBloqueo() {
        return direccionHorizontal.imagenBloqueo("guerrero")
    }

    method obtenerAnimacionAtaqueAereo() {
    return direccionHorizontal.animacionAtacandoAereo("guerrero", 4)
    }


    //-------Sonidos----------
    method sonidoAtaque() {
        const s = game.sound("espadanormal.wav")
        s.volume(0.20)
        return s
    }
        

    method obtenerAnimacionGolpeado() {
        return direccionHorizontal.animacionGolpeado("guerrero", 3)
    }

    method obtenerImagenReposo() {
        return direccionHorizontal.imagenReposo("guerrero")
    }

 // Método para configurar el estado inicial del personaje.
    method iniciar() {
        // --- Estado de vida y posición ---
    estaVivo = true
    personajeVida = 100
    position = game.at(5, 1) // Posición inicial.
    
    // --- Resetear variables de estado (ESTO ES LO QUE FALTA) ---
    velocidadVertical = 0
    movimientoHorizontal = false
    velocidadX = 0
    
    // --- Resetear estado de combate ---
    estaAtacando = false
    timerAtaque = 0
    timerInvencible = 0 
    
    // --- Resetear estado de escudo ---
    estaBloqueando = false
    energiaEscudo = maxEnergiaEscudo // Reinicia a 100
    
    // --- Resetear estado de animación ---
    direccionHorizontal = derecha
    frameActual = 0
    image = self.obtenerImagenReposo() // Asegura que la imagen sea la correcta

    // --- Actualizar HUD ---
    // Es importante reiniciar el HUD también
    barraDeVida.actualizarBarra(personajeVida)
    barraDeEnergia.actualizarBarra(energiaEscudo)
    }
// MÉTODOS DE ACCIÓN (Llamados por el teclado)
// Estos métodos no controlan la imagen ni la física, solo inician una acción.

    method moverDerecha() {
        velocidadX += 0.5
        movimientoHorizontal = true
        direccionHorizontal = derecha
    }
    
    method moverIzquierda() {
        velocidadX -= 0.5
        movimientoHorizontal = true
        direccionHorizontal = izquierda
    }


  method intentarSaltar() {
        // Solo puede saltar si está en el suelo.
        if (self.estaEnElSuelo()) {
            velocidadVertical = fuerzaSalto
        }
    }


 method alternarEscudo() {
        if (estaBloqueando) {
            self.desactivarEscudo()
        } else {
            //  Si NO está bloqueando, intenta ACTIVARLO
   
            if (not estaAtacando and energiaEscudo > umbralActivarEscudo) {
                estaBloqueando = true
            }
        }
    }
	method desactivarEscudo() {
		estaBloqueando = false
		// se podria agregar un sonido de "escudo abajo" aquí
	}


    method intentarDash() {
    const costeEnergiaDash = 25
    const distanciaDash = 8
    const duracionDash = 8
    const sonidoDash = game.sound("dash.wav")

    if (!estaHaciendoDash or !estaAtacando or !estaBloqueando or energiaEscudo > costeEnergiaDash) {
    estaHaciendoDash = true
    invenciblePorDash = true 
    timerDash = duracionDash
    self.gastarEnergia(costeEnergiaDash)

    timerInvencible = duracionDash
    velocidadX = 0

    const nuevaX = position.x() + (direccionHorizontal.empuje() * distanciaDash)

    const xLimitada = nuevaX.max(-1).min(53) //Limita los bordes del mapa

    position = game.at(xLimitada, position.y())
    
    sonidoDash.play()
    }
    
}

  // MÉTODO DE ACTUALIZACIÓN PRINCIPAL (Llamado por game.onTick)
  // Este es el corazón del objeto.
    method actualizar() {
        if (estaHaciendoDash) {
        timerDash -= 1
        if (timerDash <= 0) {
            estaHaciendoDash = false
            invenciblePorDash = false   
        }
    }
        //El timer de invencibilidad se reduce en cada tick
        if (timerInvencible > 0) {
            timerInvencible -= 1
        }
        if (not estaVivo){
            // Usamos 'estaAtacando' como bandera.
        // Si no está "atacando" (bandera libre), ejecuta el bloque de muerte y pon la bandera.
      //if (not estaAtacando) { 
            mapa.mapaActual().detenerMusica()
            finDelJuego.sonarMusica()
            image = direccionHorizontal.imagenDerrotado("guerrero")
            game.addVisual(finDelJuego)
            finDelJuego.agregarListener()
            estaAtacando = true // <-- Marcamos la bandera para que no se repita

            
       // }
        }
        else {
            self.actualizarEnergia()
            self.verificarColisionEnemigos()
            self.aplicarFisicaHorizontal() //aplicar física horizontal (movimiento).
            self.aplicarFisicaVertical() //aplicar física vertical (salto y gravedad).
            self.actualizarAnimacion()
            self.resetearMovimiento() 
        }

        //  LÓGICA DE PARPADEO

        if (estaVivo and timerInvencible > 0) {
            
            // Hacemos un "reloj" (true/false) para el parpadeo
            if (timerInvencible % 8 < 4) {  //Funciona por ticks, cuando el sobrante es 0,1,2,3 (4ticks) el personaje desaparece
                
                image = "transparente.png"
            }
            // Si el "reloj" da false, no hacemos nada,
            // y se queda la imagen que puso 'actualizarAnimacion'.
        }
    }

    method actualizarEnergia() {
		if (estaBloqueando) {
			self.gastarEnergia(costeMantenerEscudo)
		} else {
			// Recarga energía si no está bloqueando
			if (energiaEscudo < maxEnergiaEscudo) {
				energiaEscudo = (energiaEscudo + recargaEnergia).min(maxEnergiaEscudo)
			}
		}
		// Actualiza la barra de energía en la pantalla
		barraDeEnergia.actualizarBarra(energiaEscudo)
	}

    method gastarEnergia(cantidad) {
		energiaEscudo = (energiaEscudo - cantidad).max(0)
		if (energiaEscudo == 0) {
			//  Se desactiva el escudo
			self.desactivarEscudo()
		}
	}

    method verificarColisionEnemigos() {
      mapa.mapaActual().listaEnemigos().forEach({ enemigo =>
            //
            if (enemigo.estaVivo() and self.position().distance(enemigo.position()) < 1.5) {
                // Llama al método centralizado
                self.recibirGolpe(enemigo.danioDeGolpes(), enemigo)
            }
        })
        }


    method recibirEmpujon(enemigo) {
        //  Aplicar empuje vertical (siempre salta un poco)
        // Usamos max() para que el empujón reemplace un salto
        // pero no frene una caída (siempre que 'gravedad' sea negativa)
        velocidadVertical = fuerzaEmpujeVertical.max(velocidadVertical)

        // Aplicar empuje horizontal (lejos del enemigo)
        velocidadX = enemigo.direccionH().empuje() * fuerzaEmpujeHorizontal
    }

    // MÉTODOS AUXILIARES (Ayudan a organizar el código)
    method aplicarFisicaVertical() {
   // Mover el personaje según la velocidad vertical actual.
        position = position.up(velocidadVertical)

    // Si no está en el suelo, la gravedad lo afecta.
        if (not self.estaEnElSuelo()) {
            velocidadVertical += gravedad
        }

        // Control para que no se caiga por debajo del suelo.
        if (position.y() < 0) {
             position = game.at(position.x(), 1)
            velocidadVertical = 0
        }

    }


    method aplicarFisicaHorizontal() {
    const velocidadMaxima = 0.6

    if (estaBloqueando) {
			velocidadX = 0 // Frena en seco si bloquea
		}

    // Limitar velocidad para que no supere el máximo
    if (velocidadX > velocidadMaxima) {
        velocidadX = velocidadMaxima
    } else if (velocidadX < -velocidadMaxima) {
        velocidadX = -velocidadMaxima
    }

    // Mover al personaje según la velocidad
    if (position.x() < -1) {
        position = game.at(-1, position.y())
        velocidadX = 0
    } else if (position.x() > 53) {
        position = game.at(53, position.y())
        velocidadX = 0
    } else { 
        position = position.right(velocidadX)
    }

    // Aplicar fricción (frena gradualmente)
    if (velocidadX > 0) {
        velocidadX -= friccion
        if (velocidadX < 0) velocidadX = 0
    } else if (velocidadX < 0) {
        velocidadX += friccion
        if (velocidadX > 0) velocidadX = 0
    }
}
 

 // --- MÉTODO PARA LA LÓGICA DE ANIMACIÓN ---
    method actualizarAnimacion() {
        // Aumentamos el contador de frames.
        frameActual += 1
        if (estaBloqueando) {

            image = self.obtenerImagenBloqueo()

        }else if (estaAtacando) {
        
        var animacion = null

        if (not self.estaEnElSuelo()) {
            // Si NO está en el suelo, usa la animación AÉREA
            animacion = self.obtenerAnimacionAtaqueAereo()
        } else {
            // Si  está en el suelo, usa la animación normal
            animacion = self.obtenerAnimacionAtaque()
        }
        
        // Calcula cuántos ticks dura cada frame de la animación.
        const ticksPorFrame = duracionAtaque / animacion.size()

        // Calcula el índice del frame actual basándote en el tiempo transcurrido.
        const tiempoPasado = duracionAtaque - timerAtaque
        var frameIndex = (tiempoPasado / ticksPorFrame).floor()
        
        // 4. Medida de seguridad para evitar errores si el cálculo falla.
        frameIndex = frameIndex.min(animacion.size() - 1)
        
        // Muestra la imagen correcta de la lista.
        image = animacion.get(frameIndex)

        // Reduce el timer.
        timerAtaque -= 1
        
        // Si el timer llega a cero, el ataque termina.
        if (timerAtaque <= 0) {
            estaAtacando = false
        }

    } else {
        // Lógica para decidir qué animación usar.
        if (not self.estaEnElSuelo()) {
            // Si está en el aire, usa la imagen de salto.
            image = self.obtenerImagenSalto()
        
        } else if (movimientoHorizontal) {
            // Si se está moviendo a la derecha, cicla la animación de caminar.
            const frameIndex = frameActual % self.obtenerAnimacionCaminar().size()
            image = self.obtenerAnimacionCaminar().get(frameIndex)
            
        } else {
            // Si está quieto, muestra la imagen de "idle" (parado).
            image = self.obtenerImagenReposo()
        }
      }
    }
 
    method resetearMovimiento() {
        movimientoHorizontal = false
    }

    method estaEnElSuelo() {
        // Consideramos que está en el suelo si su altura es 0 o menos.
     return position.y() <= 1
    }

    method restarVida(cantidadDeDaño){
        if (estaVivo){
	    const nuevaVida = personajeVida - cantidadDeDaño
        personajeVida = 0.max(nuevaVida) //Valor maximo entre 0 y la nueva vida, se asegura que la vida no baje de 0
        barraDeVida.actualizarBarra(personajeVida)
        if (personajeVida == 0) {
            estaVivo = false
        }
      }
    }

    method atacar(){
        if (not estaAtacando /*and self.estaEnElSuelo()*/ and not estaBloqueando) {
            self.sonidoAtaque().play()
            estaAtacando = true
            timerAtaque = duracionAtaque 
            movimientoHorizontal = false

        const alcanceAtaque = 5.5 // Distancia a la que el ataque conecta.
        const danioAtaque = 25 // El daño que hace el ataque.

        // Comprobar si el ENEMIGO está dentro del alcance.
        mapa.mapaActual().listaEnemigos().forEach({ enemigo =>
        if (enemigo.estaVivo() and (self.position().distance(enemigo.position()) <= alcanceAtaque) and (direccionHorizontal.mirandoHaciaEnemigo(self.position().x(), enemigo.position().x()))) {
           
            enemigo.recibirGolpe(danioAtaque)
        }
        })
    }
    }


    method recibirGolpe(danioRecibido, enemigo) {
        // Solo nos golpean si no somos invencibles
        if (timerInvencible <= 0 and not invenciblePorDash) {
            
            var danioFinal = danioRecibido
            
            // Lógica de bloqueo
            if (estaBloqueando) { //
                danioFinal = danioRecibido * (1 - reduccionDeDanio)
                self.gastarEnergia(costeGolpeEscudo) //
            }
            
            // Quitar vida
            self.restarVida(danioFinal) //
            
            
            // Solo se activa si el golpe hizo daño (no fue 100% bloqueado)
            if (not estaBloqueando or danioFinal > 0) { 
                timerInvencible = duracionInvencible // ¡Activa el parpadeo!
                self.recibirEmpujon(enemigo) // ¡Activa el empujón!
            }
        }
    }
}