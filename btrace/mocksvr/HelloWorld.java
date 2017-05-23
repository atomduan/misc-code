import java.util.Random;  

public class HelloWorld {  
    public static Integer execute(int sleepTime) {  
        try {  
            Thread.sleep(sleepTime);  
        } catch (Exception e) {  
        }  
        System.out.println("sleep time is=>"+sleepTime);  
        return 0;  
    }  

    public static void main(String[] args) throws Exception {  
        while (true) {  
            Random random = new Random();  
            execute(random.nextInt(4000));  
        }  
    }  
}
