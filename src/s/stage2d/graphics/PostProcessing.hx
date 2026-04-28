package s.stage2d.graphics;

#if S2D_PP_BLOOM
import s.stage2d.graphics.postprocessing.Bloom;
#end
#if S2D_PP_FISHEYE
import s.stage2d.graphics.postprocessing.Fisheye;
#end
#if S2D_PP_FILTER
import s.stage2d.graphics.postprocessing.Filter;
#end
#if S2D_PP_COMPOSITOR
import s.stage2d.graphics.postprocessing.Compositor;
#end

@:dox(hide)
class PostProcessing {
	#if S2D_PP_BLOOM
	public static final bloom = new Bloom();
	#end
	#if S2D_PP_FISHEYE
	public static final fisheye = new Fisheye();
	#end
	#if S2D_PP_FILTER
	public static final filter = new Filter();
	#end
	#if S2D_PP_COMPOSITOR
	public static final compositor = new Compositor();
	#end
}
