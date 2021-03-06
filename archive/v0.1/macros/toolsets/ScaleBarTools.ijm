macro "QuickScaleBar Action Tool - C000D0eD0fD1eD1fD21D22D23D24D25D26D2aD2bD2eD2fD31D36D3bD3eD3fD41D46D4bD4eD4fD51D56D5bD5eD5fD61D66D6bD6eD6fD71D72D76D77D78D79D7aD7bD7eD7fD8eD8fD91D92D93D94D95D96D97D98D99D9aD9bD9eD9fDa1Da6DabDaeDafDb1Db6DbbDbeDbfDc1Dc6DcbDceDcfDd1Dd6DdbDdeDdfDe2De3De4De5De7De8De9DeaDeeDefDfeDffC000C111C222C333C444C555C666C777C888C999CaaaCbbbCcccCdddCeeeCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD20D27D28D29D2cD2dD30D32D33D34D35D37D38D39D3aD3cD3dD40D42D43D44D45D47D48D49D4aD4cD4dD50D52D53D54D55D57D58D59D5aD5cD5dD60D62D63D64D65D67D68D69D6aD6cD6dD70D73D74D75D7cD7dD80D81D82D83D84D85D86D87D88D89D8aD8bD8cD8dD90D9cD9dDa0Da2Da3Da4Da5Da7Da8Da9DaaDacDadDb0Db2Db3Db4Db5Db7Db8Db9DbaDbcDbdDc0Dc2Dc3Dc4Dc5Dc7Dc8Dc9DcaDccDcdDd0Dd2Dd3Dd4Dd5Dd7Dd8Dd9DdaDdcDddDe0De1De6DebDecDedDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfd" {
	runMacro("QuickScaleBar.ijm");
}

macro "FEI Crop Scalebar Action Tool - C000D03D04D05D06D07D08D09D0aD0bD0cD13D17D23D27D33D37D43D47D73D74D75D76D77D78D79D7aD7bD7cD83D87D8cD93D97D9cDa3Da7DacDb3Db7DbcDe3De4De5De6De7De8De9DeaDebDecC000C111C222C333C444C555C666C777C888C999CaaaCbbbCcccCdddCeeeCfffD00D01D02D0dD0eD0fD10D11D12D14D15D16D18D19D1aD1bD1cD1dD1eD1fD20D21D22D24D25D26D28D29D2aD2bD2cD2dD2eD2fD30D31D32D34D35D36D38D39D3aD3bD3cD3dD3eD3fD40D41D42D44D45D46D48D49D4aD4bD4cD4dD4eD4fD50D51D52D53D54D55D56D57D58D59D5aD5bD5cD5dD5eD5fD60D61D62D63D64D65D66D67D68D69D6aD6bD6cD6dD6eD6fD70D71D72D7dD7eD7fD80D81D82D84D85D86D88D89D8aD8bD8dD8eD8fD90D91D92D94D95D96D98D99D9aD9bD9dD9eD9fDa0Da1Da2Da4Da5Da6Da8Da9DaaDabDadDaeDafDb0Db1Db2Db4Db5Db6Db8Db9DbaDbbDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDddDdeDdfDe0De1De2DedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDff" {
	runMacro("FEI_Crop_Scalebar.ijm");
}

macro "Edit ScaleBarTools macros... Action Tool - C00fT4e16?" {
	QSB_macropath = getDirectory("macros") + 'QuickScaleBar.ijm';
	FEI_macropath = getDirectory("macros") + 'FEI_Crop_Scalebar.ijm';
	run("Edit...", "open="+QSB_macropath);
	run("Edit...", "open="+FEI_macropath);
}
