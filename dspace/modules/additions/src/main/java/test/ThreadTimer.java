package test;

public class ThreadTimer {

    public static void main(String[] arvs) {

//        for (int i = 0; i < 5; i++) {
//
//            try {
//
//                Thread.sleep(1000);
//                System.out.println("i = " + i);
//            } catch (Exception e) {
//                System.out.println("exception = " + e);
//            }
//
//        }

        (new Thread(new Runnable() {
            public void run() {
                int i = 0;
                i++;
                System.out.println("thread1 = " + i);


                (new Thread(new Runnable() {
                    public void run() {
                        int i = 0;
                        try {
                        while (i<1000) {
                            i++;
                            Thread.sleep(100);
                            System.out.println("thread2 = " + i);
                        }
                        }catch (Exception e){
                            System.out.println("e = " + e);
                        }
                    }
                })).start();
            }
        })).start();

//        Thread one = new Thread() {
//            public void run() {
//                try {
//                    System.out.println("Does it work?");
//
//                    Thread.sleep(1000);
//
//                    System.out.println("Nope, it doesnt...again.");
//                } catch(InterruptedException v) {
//                    System.out.println(v);
//                }
//            }
//        };

//        one.start();
//        one.checkAccess();
//        System.out.println("one = " + one.getState());


//        for (String i : items) {
//            a++;
//            if (a == 999) {
//                Thread.sleep(5000);
//                a = 0;
//            }
//            System.out.println(i + a);
//
//        }

    }
}
