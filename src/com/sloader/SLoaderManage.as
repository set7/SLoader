package com.sloader
{
	public class SLoaderManage
	{
		public function SLoaderManage()
		{
			if (_instance)
				throw new Error("SLoaderManage is Singleton");
		}
		
		private static var _instance:SLoaderManage;
		public static function get instance():SLoaderManage
		{
			if (!_instance)
				_instance = new SLoaderManage();
			return _instance;
		}
		
		//////////////////////////////////////////////////////////////////////////////////
		private var _sloaders:Object;
		public function addSLoader(named:String, sloaderd:SLoader):void
		{
			_sloaders[named] = sloaderd;
		}
		
		public function getSLoader(sloaderName):SLoader
		{
			return _sloaders[sloaderName];
		}
	}
}