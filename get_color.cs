using System;
using System.Drawing;

class Program {
    static void Main() {
        try {
            using (Bitmap bmp = new Bitmap(@"C:\Users\Dell\.gemini\antigravity\brain\5dfc7151-bf2d-4921-81c1-216e83978626\media__1775734211891.png")) {
                Color c = bmp.GetPixel(bmp.Width / 2, bmp.Height / 2);
                Console.WriteLine($"{c.R:X2}{c.G:X2}{c.B:X2}");
            }
        } catch (Exception ex) {
            Console.WriteLine("Error: " + ex.Message);
        }
    }
}
