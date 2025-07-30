// File: TestDebug.java
public class TestDebug {
    public static void main(String[] args) {
        System.out.println("Starting debug test…");
        int result = computeFactorial(5);
        System.out.println("Factorial of 5 is " + result);
        // put a breakpoint on the next line
        System.out.println("Done!");
    }

    private static int computeFactorial(int n) {
        if (n <= 1)
            return 1;
        return n * computeFactorial(n - 1);
    }
}
