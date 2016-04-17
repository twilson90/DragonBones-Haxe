package dragonbones.core;

import dragonBones.objects.ParentTransformObject;
import flash.geom.Matrix;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.objects.DBTransform;
import dragonBones.utils.TransformUtil;

use namespace dragonBones_internal;

class DBObject
{
	public var name:String;

	/**
	 * An object that can contain any user extra data.
	 */
	public var userData:Object;

	/**
	 * 
	 */
	public var inheritRotation:Bool;

	/**
	 * 
	 */
	public var inheritScale:Bool;

	/**
	 * 
	 */
	public var inheritTranslation:Bool;

	/** @private */
	dragonBones_private var _global:DBTransform;
	/** @private */
	dragonBones_private var _globalTransformMatrix:Matrix;

	dragonBones_internal static var _tempParentGlobalTransformMatrix:Matrix = new Matrix();
	dragonBones_internal static var _tempParentGlobalTransform:DBTransform = new DBTransform();


	/**
	 * This DBObject instance global transform instance.
	 * @see dragonBones.objects.DBTransform
	 */
	public var global(getGlobal, setGlobal):DBTransform;
		private function getGlobal():DBTransform
	{
		return _global;
	}

	/** @private */
	private var _origin:DBTransform;
	/**
	 * This DBObject instance related to parent transform instance.
	 * @see dragonBones.objects.DBTransform
	 */
	public var origin(getOrigin, setOrigin):DBTransform;
		private function getOrigin():DBTransform
	{
		return _origin;
	}

	/** @private */
	private var _offset:DBTransform;
	/**
	 * This DBObject instance offset transform instance (For manually control).
	 * @see dragonBones.objects.DBTransform
	 */
	public var offset(getOffset, setOffset):DBTransform;
		private function getOffset():DBTransform
	{
		return _offset;
	}

	/** @private */
	private var _visible:Bool;
	public var visible(getVisible, setVisible):Bool;
		private function getVisible():Bool
	{
		return _visible;
	}
	private function setVisible(value:Bool):Void
	{
		_visible = value;
	}

	/** @private */
	private var _armature:Armature;
	/**
	 * The armature this DBObject instance belongs to.
	 */
	public var armature(getArmature, null):Armature;
		private function getArmature():Armature
	{
		return _armature;
	}
	/** @private */
	dragonBones_private function setArmature(value:Armature):Void
	{
		_armature = value;
	}

	/** @private */
	dragonBones_private var _parent:Bone;
	/**
	 * Indicates the Bone instance that directly contains this DBObject instance if any.
	 */
	public var parent(getParent, null):Bone;
		private function getParent():Bone
	{
		return _parent;
	}
	/** @private */
	dragonBones_private function setParent(value:Bone):Void
	{
		_parent = value;
	}

	public function new()
	{
		_globalTransformMatrix = new Matrix();
		
		_global = new DBTransform();
		_origin = new DBTransform();
		_offset = new DBTransform();
		_offset.scaleX = _offset.scaleY = 1;
		
		_visible = true;
		
		_armature = null;
		_parent = null;
		
		userData = null;
		
		this.inheritRotation = true;
		this.inheritScale = true;
		this.inheritTranslation = true;
	}

	/**
	 * Cleans up any resources used by this DBObject instance.
	 */
	public function dispose():Void
	{
		userData = null;
		
		_globalTransformMatrix = null;
		_global = null;
		_origin = null;
		_offset = null;
		
		_armature = null;
		_parent = null;
	}

	private function calculateRelativeParentTransform():Void
	{
	}

	private function calculateParentTransform():ParentTransformObject
	{
		if(this.parent && (this.inheritTranslation || this.inheritRotation || this.inheritScale))
		{
		var parentGlobalTransform:DBTransform = this._parent._globalTransformForChild;
		var parentGlobalTransformMatrix:Matrix = this._parent._globalTransformMatrixForChild;
		//if(!this.inheritTranslation || !this.inheritRotation || !this.inheritScale)
		//{
			//parentGlobalTransform = DBObject._tempParentGlobalTransform;
			//parentGlobalTransform.copy(this._parent._globalTransformForChild);
			//if(!this.inheritTranslation)
			//{
			//parentGlobalTransform.x = 0;
			//parentGlobalTransform.y = 0;
			//}
			//if(!this.inheritScale)
			//{
			//parentGlobalTransform.scaleX = 1;
			//parentGlobalTransform.scaleY = 1;
			//}
			//if(!this.inheritRotation)
			//{
			//parentGlobalTransform.skewX = 0;
			//parentGlobalTransform.skewY = 0;
			//}
			//
			//parentGlobalTransformMatrix = DBObject._tempParentGlobalTransformMatrix;
			//TransformUtil.transformToMatrix(parentGlobalTransform, parentGlobalTransformMatrix);
		//}
		
		return ParentTransformObject.create().setTo(parentGlobalTransform, parentGlobalTransformMatrix);
		}
		TransformUtil.transformToMatrix(_global, _globalTransformMatrix);
		return null;
	}

	private function updateGlobal():ParentTransformObject
	{
		calculateRelativeParentTransform();
		var output:ParentTransformObject = calculateParentTransform();
		if(output != null)
		{
		//计算父骨头绝对坐标
		var parentMatrix:Matrix = output.parentGlobalTransformMatrix;
		var parentGlobalTransform:DBTransform = output.parentGlobalTransform;
		//计算绝对坐标
		var x:Float = _global.x;
		var y:Float = _global.y;
		
		_global.x = parentMatrix.a * x + parentMatrix.c * y + parentMatrix.tx;
		_global.y = parentMatrix.d * y + parentMatrix.b * x + parentMatrix.ty;
		
		if(this.inheritRotation)
		{
			_global.skewX += parentGlobalTransform.skewX;
			_global.skewY += parentGlobalTransform.skewY;
		}
		
		if(this.inheritScale)
		{
			_global.scaleX *= parentGlobalTransform.scaleX;
			_global.scaleY *= parentGlobalTransform.scaleY;
		}
		}
		TransformUtil.transformToMatrix(_global, _globalTransformMatrix);
		return output;
	}
}