/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
#ifndef OOSiOSSDK_OOSServiceEnum_h
#define OOSiOSSDK_OOSServiceEnum_h

/**
 *  Enums for OOS regions.
 *
 *  For information about which regions are supported for each service, see the linked website:
 *  http://docs.OOS.amazon.com/general/latest/gr/rande.html
 */
typedef NS_ENUM(NSInteger, OOSRegionType) {
    /**
     *  Unknown Region
     */
    OOSRegionUnknown NS_SWIFT_NAME(Unknown),
    /**
     *  杭州
     */
    OOSRegionHangZhou NS_SWIFT_NAME(HangZhou),
	/**
	 *  江苏
	 */
	OOSRegionJiangShu NS_SWIFT_NAME(JiangShu),
	/**
	 *  长沙
	 */
	OOSRegionChangSha NS_SWIFT_NAME(ChangSha),
	/**
	 *  广州
	 */
	OOSRegionGuangZhou NS_SWIFT_NAME(GuangZhou),
	/**
	 *  西安
	 */
	OOSRegionXiAn NS_SWIFT_NAME(XiAn),
	/**
	 *  北京2
	 */
	OOSRegionBeiJing2 NS_SWIFT_NAME(Beijing2),
	/**
	 *  内蒙
	 */
	OOSRegionNeiMeng NS_SWIFT_NAME(NeiMeng),
	/**
	 *  内蒙2
	 */
	OOSRegionNeiMeng2 NS_SWIFT_NAME(NeiMeng2),
	/**
	 *  上海高品质
	 */
	OOSRegionShangHaiHQ NS_SWIFT_NAME(ShangHaiHQ),
	/**
	 *  北京高品质
	 */
	OOSRegionBeiJingHQ NS_SWIFT_NAME(BeiJingHQ),
	
	/**
	 *  福建
	 */
	OOSRegionFuJian NS_SWIFT_NAME(FuJian),
	/**
	 *  福建2
	 */
	OOSRegionFuJian2 NS_SWIFT_NAME(FuJian2),
	/**
	 *  郑州
	 */
	OOSRegionZhengZhou NS_SWIFT_NAME(ZhengZhou),
	/**
	 *  沈阳
	 */
	OOSRegionShenYang NS_SWIFT_NAME(ShenYang),
	/**
	 *  石家庄
	 */
	OOSRegionShiJiaZhuang NS_SWIFT_NAME(ShiJiaZhuang),
	/**
	 *  浙江金华
	 */
	OOSRegionJinHua NS_SWIFT_NAME(JinHua),
	/**
	 *  成都
	 */
	OOSRegionChengDu NS_SWIFT_NAME(ChengDu),
	/**
	 *  乌鲁木齐
	 */
	OOSRegionWuLuMuQi NS_SWIFT_NAME(WuLuMuQi),
	/**
	 *  甘肃兰州
	 */
	OOSRegionGanShuLanZhou NS_SWIFT_NAME(GanShuLanZhou),
	/**
	 *  山东青岛
	 */
	OOSRegionShanDongQingDao NS_SWIFT_NAME(ShanDongQingDao),
	/**
	 *  贵州贵阳
	 */
	OOSRegionGuiZhouGuiYang NS_SWIFT_NAME(GuiZhouGuiYang),
	/**
	 *  湖北武汉
	 */
	OOSRegionHuBeiWuHan NS_SWIFT_NAME(HuBeiWuHan),
	/**
	 *  西藏拉萨
	 */
	OOSRegionXiZangLaSa NS_SWIFT_NAME(XiZangLaSa),
	/**
	 *  安徽芜湖
	 */
	OOSRegionAnHuiWuHu NS_SWIFT_NAME(AnHuiWuHu),
	
};

/**
 *  Enums for ctyun services.
 */
typedef NS_ENUM(NSInteger, OOSServiceType) {
	/**
	 *  Unknown service
	 */
	OOSServiceUnknown NS_SWIFT_NAME(Unknown),
	/**
	 *   Simple Storage Service (S3)
	 */
	OOSServiceS3 NS_SWIFT_NAME(S3),
};

#endif
