//TEST(compute):COMPARE_COMPUTE:-dx11
//TEST(compute):COMPARE_COMPUTE:-vk
//TEST(compute):COMPARE_COMPUTE:-cpu -xslang -disable-specialization
//TEST(compute):COMPARE_COMPUTE:-cuda -xslang -disable-specialization

// Test dynamic dispatch code gen for associated-typed return values
// and local variables.
// TODO: test arguments of associated type.
[anyValueSize(8)]
interface IAssoc
{
    int Compute();
}
[anyValueSize(16)]
interface IInterface
{
    associatedtype TAssoc : IAssoc;

    [mutating]
    void SetVal(int inVal);

    TAssoc GetAssoc();
};

T.TAssoc CreateT_Assoc_Inner<T:IInterface>(int inVal)
{
    T obj;
    obj.SetVal(inVal);
    return obj.GetAssoc();
}

T.TAssoc CreateT_Assoc<T:IInterface>(int inVal)
{
    return CreateT_Assoc_Inner<T>(inVal);
}

T CreateT<T:IInterface>(int inVal)
{
    T obj;
    obj.SetVal(inVal);
    return obj;
}

struct Impl : IInterface
{
    struct TAssoc : IAssoc
    {
        int base;
        int Compute()
        {
            return base;
        }
    };

    TAssoc assoc;
    [mutating]
    void SetVal(int inVal)
    {
        assoc.base = inVal;
    }

    TAssoc GetAssoc()
    {
        return assoc;
    }
};

int test()
{
    var obj = CreateT<Impl>(2);
    var obj2 = CreateT_Assoc<Impl>(1);
    // TODO: compiler crash if type parameter is missing.
    // (hitting lowering logic of TypeEqualityWitness)
    var obj3 = CreateT_Assoc_Inner<Impl>(1);
    return obj.GetAssoc().Compute() + obj2.Compute() + obj3.Compute();
}

//TEST_INPUT:ubuffer(data=[0 1 2 3], stride=4):out,name=outputBuffer
RWStructuredBuffer<int> outputBuffer;

[numthreads(4, 1, 1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID)
{
    uint tid = dispatchThreadID.x;
    int outVal = test();
    outputBuffer[tid] = outVal;
}
