# Taller de Arduino y Processing

Taller orientado a temas avanzados de microcontroladores y Arduino en particular.
Además se introduce el lenguaje de programación Processing, la intercacción con Arduino y librerías útiles para
generar interfaces gráficas.

## Arduino

1. [Timer](https://github.com/pcremades/Taller_Arduino-Processing/tree/master/Timer2): configuración del TIMER2 para generar eventos cada 1 segundo.
2. PWM: generación de [señales armónicas](https://github.com/pcremades/Taller_Arduino-Processing/tree/master/PWM_Test). Esta aplicación cambia la
configuración del TIMER2 para utilizar el PWM a la máxima frecuencia posible y genera una onda senoidal. Debe utilizarse
un filtro pasabajos RC a la salida para reconstruir la señal.
3. PWM: generación de [señales arbitrarias](https://github.com/pcremades/Taller_Arduino-Processing/tree/master/PWM_Test_Serial). Esta aplicación cambia la
configuración del TIMER2 para utilizar el PWM a la máxima frecuencia posible. Recibe por puerto serie una lista de valores de ancho
de pulso, que son los que defienen la forma de la onda. Debe utilizarse un filtro pasabajos RC a la salida para reconstruir la señal.
4. [Frecuencímetro](https://github.com/pcremades/Taller_Arduino-Processing/tree/master/PulseCounter): aplicación para medir frecuencia
de una señal cuadrada. Ideal para el [sensor de color]().
5. [Sensor de distancia infrarrojo](https://github.com/pcremades/Taller_Arduino-Processing/tree/master/IR_Sensor): simple aplicación para
leer el [sensor infrarrojo de distancia](). [Aquí](https://github.com/pcremades/Taller_Arduino-Processing/tree/master/IR_SensorProcessing)
puede encontrar una aplicación para graficar los datos del sensor en tiempo real.
