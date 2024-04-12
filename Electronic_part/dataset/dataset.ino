#include <SPI.h>    //Se incluye la librería de la comunicación SPI
#include <SD.h>   //Se incluye la librería de la tarjeta SD
#include <DHT.h>    //Se incluye la librería de DHT del sensor
#include<DHT_U.h>   //Se incluye la librería DHT_U
#define SENSOR 2    //Se define al sensor como una constante llamada "SENSOR" EN EL PIN2
#include <Wire.h>   // Incluye la librería del i2c
#include <RTClib.h>   //Se incluye la libería del reloj
#include <LiquidCrystal_I2C.h>  //Se incluye la librería para la pantalla lcd con bus I2C
LiquidCrystal_I2C lcd (0x27, 16, 2);  //Se crea un objeto del tipo "LiquidCrystal_I2C" llamado "lcd", con los siguientes parametros; dirección hexadecimal y cantidad de columnas y filas

#define SENSOR 2    //Se define al sensor como una constante llamada "SENSOR" EN EL PIN2
int TEMPERATURA;    //Se declara una variable llamada TEMPERATURA
int HUMEDAD;    //Se crea una variable llamada HUMEDAD

#define SSpin 10    //Se define al SSpin en el pin de 10 para el selector de esclavo de la comunciación SPI de la tarjeta SD

File archivo;   //Se crea un bojeto del tipo file llamado "archivo"
DHT dht(SENSOR, DHT11);   //Se crea un objeto del tipi DHT llamado "dht" con los parametros de pin y el tipo de dht que es
RTC_DS3231 rtc;   //Se crea un objeto del tipo "RTC_DS3231" llamado "rtc"
void initRTC(){
  Serial.begin(9600);   //Se inicializa el monitor serie
    if(!rtc.begin()){   //Si la inicialización es incorrecta
    Serial.println("modulo rtc no encontrado" );    //Se escribe que el "modulo rtc no encontrado"
    while(1);   //Y se queda estancado en este bucle
  }
  rtc.adjust(DateTime(__DATE__,__TIME__));   //Se ajusta la fecha y la hora
  
}
void initDHT(){  
  Serial.begin(9600);   //Se inicia la comunicación serie 
  dht.begin();    //Se inicia el sensor dht
}
void initSDCARD(){
lcd.setCursor(0, 0);
lcd.print("Inicializando tarjeta...");   //Se escribe en el monitor serie "Inicializando tarjeta..."
if(!SD.begin(SSpin)){ //Si la inicialización del SD es correcta, o en su defecto, incorrecta 
  lcd.print("fallo en inicialización");  //Si es incorrecta,el monitor serie escribirá "fallo en inicialización" 
  return;   //Y se queda estancado 
}

lcd.print("inicialización correcta");  //Si es correcta, el monitor serie escribirá "inicialización correcta"
}
void initLCD(){
  Wire.begin();   //Se inicializa la conexión I2C
  lcd.init();   //Se inicializa la pantalla
  lcd.clear();  //Se limpia la pantalla de cualquier texto
  lcd.setBacklight(HIGH); //Se enciende el foco trasero de la pantalla
}
void WritingFile(){
  
  archivo= SD.open("dataset.csv", FILE_WRITE); //El archivo, abrirá y creará un documento llamado "TH.txt", y con la función "FILE_WRITE"
  lcd.clear();
  if (archivo) {    //Entramos a un condicional if del archivo si es correcto.... Si es incorrecto...
  archivo.print("Index");
  archivo.print(",");
  archivo.print("Temperature");
  archivo.print(",");
  archivo.print("Humidity");
  archivo.print(",");
  archivo.println("DATE");
  Serial.print("Index");
  Serial.print(",");
  Serial.print("Temperature");
  Serial.print(",");
  Serial.print("Humidity");
  Serial.print(",");
  Serial.println("DATE");
    for(int i=1; i < 8641; i++){    //Y se crea un bucle for con un limite de 31 datos distinctos que dichos, se escibirán en el archivo TH.txt
      DateTime fecha =rtc.now();
      TEMPERATURA =dht.readTemperature();   //TEMPERATURA= a la lectura de la temperatura
      HUMEDAD = dht.readHumidity();  //HUMEDAD es igual, a la lectura de humedad 
      uint8_t day=fecha.day();
      uint8_t month=fecha.month();
      uint16_t year=fecha.year();
      uint8_t hour=fecha.hour();
      uint8_t minute=fecha.minute();
      uint8_t second=fecha.second();
      //ARCHIVO
      archivo.print(i); //En el acrhivo se escribira el numero de veces
      archivo.print(","); //Se escribiran comas para diferenciarlo
      archivo.print(TEMPERATURA); //Se escribe el valor de la TEMPERATURA
      archivo.print(","); //Se escribe una coma para diferenciarlo
      archivo.print(HUMEDAD); //Se escribe el valor leído en HUMEDAD
      archivo.print(",");
      archivo.print(day);
      archivo.print("/");
      archivo.print(month);
      archivo.print("/");
      archivo.print(year);
      archivo.print(" ");
      archivo.print(hour);
      archivo.print(":");
      archivo.print(minute);
      archivo.print(":");
      archivo.println(second);
      //Monitor serie
      Serial.print(i);    //En el monitor serie, se escribe el valor de vez
      Serial.print(",");    //Se escribe una coma
      Serial.print(TEMPERATURA);    //Se escribe el valor leído en TEMPERATURA
      Serial.print(",");  //Se escribe una coma
      Serial.println(HUMEDAD);    //Se ecribe el valor leído en HUMEDAD
      Serial.print(",");
      Serial.print(day);
      Serial.print("/");
      Serial.print(month);
      Serial.print("/");
      Serial.print(year);
      Serial.print(" ");
      Serial.print(hour);
      Serial.print(":");
      Serial.print(minute);
      Serial.print(":");
      Serial.println(second);
      //LCD
      lcd.setCursor(0,0);
      lcd.print(i);    //En el monitor serie, se escribe el valor de vez
      lcd.print(",");    //Se escribe una coma
      lcd.print(TEMPERATURA);    //Se escribe el valor leído en TEMPERATURA
      lcd.print(",");  //Se escribe una coma
      lcd.print(HUMEDAD);    //Se ecribe el valor leído en HUMEDAD
      lcd.print(",");
      lcd.print(day);
      lcd.print("/");
      
      lcd.print(month);
      lcd.setCursor(0,1);
      lcd.print("/");
      lcd.print(year);      
      lcd.print(" ");
      lcd.print(hour);
      lcd.print(":");
      lcd.print(minute);
      lcd.print(":");
      lcd.print(second);
      

      delay(10000); //Las veces que lo haga será en cada segundo
      
    }
    archivo.close();  //El archivo se cierra
    Serial.println("escritura correcta"); //Si es correcto, se escribe "escritura correcta"
        }else{//Si no es correcto
          Serial.println("error en apertura de datos.txt");     //Se escribe "error en apertura de datos.txt"
        }
  }
void setup() {
  initLCD();
  initRTC();
  initDHT();
  initSDCARD();
  WritingFile();

}

void loop() {
  //Se obtienen todos los datos de fecha y horario con la función now, por lo que la fecha, es igual a todos esos datos
  //Se imprime la fecha en el monitor serie 
  /*    DateTime fecha =rtc.now();
      uint8_t day=fecha.day();
      uint8_t month=fecha.month();
      uint8_t year=fecha.year();
      uint8_t hour=fecha.hour();
      uint8_t minute=fecha.minute();
      uint8_t second=fecha.second();
      String complete = String(day) + "/" + String(month) + "/" + String(year) + " " + String(hour) + ":" + String(minute) + ":" + String(second);


      Serial.println(complete);
      delay(1000);   //Se hará cada 1 segundo
*/
 
}