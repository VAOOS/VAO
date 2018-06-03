pragma solidity ^0.4.4;
library StringUtils {
    /// @dev Does a byte-by-byte lexicographical comparison of two strings.
    /// @return a negative number if `_a` is smaller, zero if they are equal
    /// and a positive numbe if `_b` is smaller.
    function compare(string _a, string _b) returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }
    /// @dev Compares two strings and returns true iff they are equal.
    function equal(string _a, string _b) returns (bool) {
        return compare(_a, _b) == 0;
    }
    /// @dev Finds the index of the first occurrence of _needle in _haystack
    function indexOf(string _haystack, string _needle) returns (int)
    {
    	bytes memory h = bytes(_haystack);
    	bytes memory n = bytes(_needle);
    	if(h.length < 1 || n.length < 1 || (n.length > h.length)) 
    		return -1;
    	else if(h.length > (2**128 -1)) // since we have to be able to return -1 (if the char isn't found or input error), this function must return an "int" type with a max length of (2^128 - 1)
    		return -1;									
    	else
    	{
    		uint subindex = 0;
    		for (uint i = 0; i < h.length; i ++)
    		{
    			if (h[i] == n[0]) // found the first char of b
    			{
    				subindex = 1;
    				while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) // search until the chars don't match or until we reach the end of a or b
    				{
    					subindex++;
    				}	
    				if(subindex == n.length)
    					return int(i);
    			}
    		}
    		return -1;
    	}	
    }
}


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a - b;
        assert(b <= a);
        assert(a == c + b);
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        assert(a == c - b);
        return c;
    }
}
/// @dev Models a uint -> uint mapping where it is possible to iterate over all keys.
library IterableMapping
{
  struct itmap
  {
    mapping(uint => IndexValue) data;
    KeyFlag[] keys;
    uint size;
  }
  struct IndexValue { uint keyIndex; uint value; }
  struct KeyFlag { uint key; bool deleted; }
  function insert(itmap storage self, uint key, uint value) returns (bool replaced)
  {
    uint keyIndex = self.data[key].keyIndex;
    self.data[key].value = value;
    if (keyIndex > 0)
      return true;
    else
    {
      keyIndex = self.keys.length++;
      self.data[key].keyIndex = keyIndex + 1;
      self.keys[keyIndex].key = key;
      self.size++;
      return false;
    }
  }
  function remove(itmap storage self, uint key) returns (bool success)
  {
    uint keyIndex = self.data[key].keyIndex;
    if (keyIndex == 0)
      return false;
    delete self.data[key];
    self.keys[keyIndex - 1].deleted = true;
    self.size --;
  }
  function contains(itmap storage self, uint key) returns (bool)
  {
    return self.data[key].keyIndex > 0;
  }
  function iterate_start(itmap storage self) returns (uint keyIndex)
  {
    return iterate_next(self, uint(-1));
  }
  function iterate_valid(itmap storage self, uint keyIndex) returns (bool)
  {
    return keyIndex < self.keys.length;
  }
  function iterate_next(itmap storage self, uint keyIndex) returns (uint r_keyIndex)
  {
    keyIndex++;
    while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
      keyIndex++;
    return keyIndex;
  }
  function iterate_get(itmap storage self, uint keyIndex) returns (uint key, uint value)
  {
    key = self.keys[keyIndex].key;
    value = self.data[key].value;
  }
}

contract contracts {
    //角色类型 其他 顾客 制造商  零售商 
    enum AssetType{
        Card,
        GoldCoin, 
        Equipment
    }
    
    enum RateType{
        Card,
        GoldCoin, 
        Equipment
    }
    
	//用户结构体   
    struct User{
        bytes32 ID;
        bytes32 name;
        uint256 totalAsset;

        mapping (bytes32 => uint256) assets;
    }
    
    //用户map
    mapping(bytes32 => User) UserMap;


    //兑换利率 1:xx;  之一个资产能兑换多少个value
    mapping (string => uint256) rate;

    //白名单
    mapping(address => bool) whiteList;    

    //合约拥有者
    address owner;
    

     // 构造函数  首次创建将自己设为白名单
     //设置所有利率为1:1;
    function contracts(){
        owner = msg.sender;
        whiteList[owner] = true;
    
        rate["Card"] = 1;
        rate["GoldCoin"] = 1;
        rate["Equipment"] = 1;
    }
    
    
    
    //设置利率
    function setRateByType(RateType ratetype,uint256 rateValue) returns (bool,string){
        
        //根据不同的利率设置不同的rate
        if(ratetype == RateType.Card){
             rate["Card"] = rateValue;
        }else if(ratetype == RateType.GoldCoin){
            rate["GoldCoin"] = rateValue;
        }else if(ratetype == RateType.Equipment){
            rate["Equipment"] = rateValue;
        }else{
            return (false , "No exit such a rateType");
        }
        return (true , "set rate done");
        
    }


    // 添加白名单
    function addWhiteList(address addr){
        whiteList[addr] = true;
    }
    
    
    
    //添加用户 
    function newUser(bytes32 ID, bytes32 name) returns(bool, string){    


        // 校验是否白名单
          if(whiteList[msg.sender] != true){
            return(false,"Have no right to call");        
        }
        

        // 校验是否存在
        User user = UserMap[ID];
        if(user.ID != 0x0){
            return (false, "this ID has been occupied!");
        }

        // 置信息
        user.ID = ID;
        user.name = name;
        user.totalAsset = 0;
        return (true, "Success");
    }



    // 根据ID获取资产类型
    function getAssetByIDAndTyep(bytes32 ID,AssetType assetType) returns (bool, string, uint256 value){

        //获取校验
        User user = UserMap[ID];   
        if(user.ID == 0x0){
            return (false, "The ID is not exist!",value);
        }
        

        //返回不同的value
        if(assetType == AssetType.Card){
            return (true, "get done!",user.assets["Card"]);
        }else if(assetType == AssetType.Equipment){
            return (true, "get done!",user.assets["Equipment"]);
        }else if(assetType == AssetType.GoldCoin){
            return (true, "get done!",user.assets["GoldCoin"]);
        }else{
            return (false,"No such a assetType",value);
        }

    }
    

    // 设置资产
    function setValueByIDAndType (bytes32 ID,AssetType assetType,uint256 assetValue) returns (bool,string){
        // 校验是否为白名单操作
        if(whiteList[msg.sender] != true){
            return(false,"Have no right to call");        
        }

        //获取user
        User user = UserMap[ID];   
        
         // userid错误
        if(user.ID == 0x0){
            return (false, "The ID is not exist!");
        }
        

        // 根据不同的Type 设置对应的value
        if(assetType == AssetType.Card){
            user.assets["Card"] = assetValue;    
        }else if(assetType == AssetType.Equipment){
            user.assets["Equipment"] = assetValue;    
        }else if(assetType == AssetType.GoldCoin){
            user.assets["GoldCoin"] = assetValue;    
        }else{
            return (false,"No such a assetType");
        }
        
        //计算出该用户的全部Value
        user.totalAsset = user.assets["GoldCoin"] * rate["GoldCoin"] + user.assets["Card"] *  rate["Card"] +  user.assets["Equipment"] * rate["Equipment"];
        return (true, "set done!");
    }
    
    

    //资产转移
    function  assetTransformation(bytes32 fromID,bytes32 toID,AssetType assetType,uint256 value ) returns (bool,string) {
        
        //校验是否白名单
         if(whiteList[msg.sender] != true){
            return(false,"Have no right to call");        
        }

        // 取出fromuser和touser

        
        User fromuser = UserMap[fromID];
        User touser = UserMap[toID];
        

        //分别校验
        if(fromuser.ID == 0x0){
            return (false, "The fromID is not exist!");
        }
        
        if(touser.ID == 0x0){
            return (false, "The toID is not exist!");
        }
        


        //根据类型执行不同资产的转移
         if(assetType == AssetType.Card){
         

             //首先校验资产是否满足转移条件
            if(fromuser.assets["Card"] < value){
                return( false,"the fromID doesn't hava enough value");
            }

            //转移
            fromuser.assets["Card"] = fromuser.assets["Card"] - value;
            touser.assets["Card"] = touser.assets["Card"] + value;
            return( true,"Transformation done");
        
        }else if(assetType == AssetType.Equipment){
            if(fromuser.assets["Equipment"] < value){
                return( false,"the fromID doesn't hava enough value");
            }
            fromuser.assets["Equipment"] = fromuser.assets["Equipment"] - value;
            touser.assets["Equipment"] = touser.assets["Equipment"] + value;
            return( true,"Transformation done");
            
            
        }else if(assetType == AssetType.GoldCoin){
            if(fromuser.assets["GoldCoin"] < value){
                return( false,"the fromID doesn't hava enough value");
            }
            fromuser.assets["GoldCoin"] = fromuser.assets["GoldCoin"] - value;
            touser.assets["GoldCoin"] = touser.assets["GoldCoin"] + value;
            return( true,"Transformation done");
        }else{
            return (false,"No such a assetType");
        }
    }
}
