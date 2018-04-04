# Toolbox for panorama image processing

Please refer to instruction.pdf for details about supporting fuctions.

If use this code as part of your project, please cite:

Y. Zhang, S. Song, P. Tan, and J. Xiao  
PanoContext: A Whole-room 3D Context Model for Panoramic Scene Understanding  
Proceedings of the 13th European Conference on Computer Vision (ECCV2014)

    @article{zhang2014panocontext,
      title={Panocontext: A whole-room 3d context model for panoramic scene understanding},
      author={Zhang, Yinda and Song, Shuran and Tan, Ping and Xiao, Jianxiong},
      booktitle={European Conference on Computer Vision},
      pages={668--686},
      year={2014},
      organization={Springer}
    }



If you have any question about the code, please feel free to contact:
Yinda Zhang, yindaz at cs dot princeton dot edu



## Quick start:
Run `demo_full.m` to see an "almost" complete list of functions in this toolbox. Some (not all) featured functions are:
- Combine perspective images to a panorama.
- Project a region on panorama to a perspective image.
- Line segment detection.
- Color segmentation.
- Find vanishing point.
- Reconstruct 3D cuboid.

For a full list of functions, please see `instruction.pdf`.

## Matterport3D support:
Run `demo_matterport.m` to see how to stitch panorama for Matterport3D dataset. Note that:
- If you wish to have seamless good looking color panorama, you should stitch skybox images.
- If you wish to have aligned color and depth panorama, you should stitch undistorted_color/depth_images.

If you stitch from undistorted_color/depth_images:
- The color panorama from undistorted_color_images may contain visible artifacts near stitching boundaries because of different exposure between images.
- The demo only takes the 6 horizontal views as example, and assumes 60 degrees between each pair of adjacent views. This may not be true in practice, and a perfectly accurate panorama stitching requires accurate calculation of (vx,vy) from camera extrinsic matrices.
- Given more accurate (vx/vy) calculated for upward/downward looking views, you may stitch 18 views together for a more complete panorama.



## FAQ:
Q: Windows users will get an error when calling function "lsdWrap.m".  
A: The Windows command line does not support '/'. Please change all '/' in commands line to '\\' before sending them to "system" function in Matlab.


## License:
This toolbox is under the MIT License: http://opensource.org/licenses/MIT.
