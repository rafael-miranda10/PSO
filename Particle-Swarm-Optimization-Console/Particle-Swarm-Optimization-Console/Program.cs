using Emgu.CV;
using Emgu.CV.Structure;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;

namespace Particle_Swarm_Optimization_Console
{
    class Program
    {
        static void Main(string[] args)
        {
            string path = Environment.CurrentDirectory;
            path = path.Replace(@"Particle-Swarm-Optimization-Console\bin\Debug", "");

            //####################  exemplos com imagem     ##########################

            var ImgTarget = new Image<Bgra, byte>(path + @"\Images\Formas.bmp");
            // CvInvoke.Imshow("Formas Image", ImgFormas);
            var ImgTemplate = new Image<Bgra, byte>(path + @"\Images\quadrado.bmp");
            // CvInvoke.Imshow("Quadrado Image", ImgQudrado);
            Image<Gray, byte> _imgTargetGray = ImgTarget.Convert<Gray, Byte>();
            Image<Gray, byte> _imgTemplateGray = ImgTemplate.Convert<Gray, Byte>();
           CvInvoke.Imshow("Formas Gray", _imgTargetGray);
           CvInvoke.Imshow("Quadrado Gray ", _imgTemplateGray);


            int swarmSize = 100;
            int iterations = 100;
            double inertia = 0.9;
            double correctionFactor1 = 2.5; // c1
            double correctionFactor2 = 2.5; // c2
            List<Particle> swarmParticles = new List<Particle>();
            Random random = new Random();

            for (int i = 0; i < swarmSize; i++)
            {
                var particle = new Particle
                {
                    xPosition = (int)Math.Floor((_imgTargetGray.Width - _imgTemplateGray.Width) * random.NextDouble()) + (int)Math.Floor(_imgTemplateGray.Width / 2.0) + 1,
                    yPosition = (int)Math.Floor((_imgTargetGray.Height - _imgTemplateGray.Height) * random.NextDouble()) + (int)Math.Floor(_imgTemplateGray.Height / 2.0) + 1,
                    pBest = 1000, // valor inicial do pBest
                    velocity = 0 // velocidade inicial
                };

                swarmParticles.Add(particle);
            }

            //iterações
            for (int iter = 0; iter < iterations; iter++)
            {
                //Evolui a particula
                // posição nova = posição atual + velocidade
                for (int part = 0; part < swarmSize; part++)
                {
                    swarmParticles[part].xPosition += (int)swarmParticles[part].velocity;
                    swarmParticles[part].yPosition += (int)swarmParticles[part].velocity;

                    Rectangle crop_region = new Rectangle(swarmParticles[part].xPosition, swarmParticles[part].yPosition, _imgTemplateGray.Width, _imgTemplateGray.Height);
                    _imgTargetGray.ROI = crop_region;
                    Image<Gray, byte> imageCroped = _imgTargetGray.CopyBlank();
                    _imgTargetGray.CopyTo(imageCroped);
                    _imgTargetGray.ROI = Rectangle.Empty;

                    Image<Gray, byte> imageToShow = _imgTargetGray.Copy();


                   // using (Image<Gray, float> result = imageCroped.MatchTemplate(_imgTemplateGray, Emgu.CV.CvEnum.TemplateMatchingType.CcoeffNormed))// Emgu.CV.CvEnum.TM_TYPE.CV_TM_CCOEFF_NORMED))
                    using (Image<Gray, float> result = _imgTemplateGray.MatchTemplate(_imgTemplateGray, Emgu.CV.CvEnum.TemplateMatchingType.CcoeffNormed))// Emgu.CV.CvEnum.TM_TYPE.CV_TM_CCOEFF_NORMED))
                    {
                        double[] minValues, maxValues;
                        Point[] minLocations, maxLocations;
                        result.MinMax(out minValues, out maxValues, out minLocations, out maxLocations);

                        // You can try different values of the threshold. I guess somewhere between 0.75 and 0.95 would be good.
                        if (maxValues[0] > 0.9)
                        {
                            // This is a match. Do something with it, for example draw a rectangle around it.
                            Rectangle match = new Rectangle(maxLocations[0], _imgTemplateGray.Size);
                            //imageToShow.Draw(match, new Bgr(Color.Red), 3);
                            imageToShow.Draw(crop_region, new Gray(0), 3);
                            CvInvoke.Imshow("Imagem Macth", imageToShow);
                            CvInvoke.WaitKey();
                        }
                    }



                  // CvInvoke.Imshow("Imagem Cortada", imageCroped);
                  //  CvInvoke.WaitKey();
                }

            }

          //  CvInvoke.WaitKey();
        }
    }
}
