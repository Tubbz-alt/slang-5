//TEST_CATEGORY(wave, compute)
//DISABLE_TEST:COMPARE_COMPUTE_EX:-cpu -compute 
//DISABLE_TEST:COMPARE_COMPUTE_EX:-slang -compute
//TEST:COMPARE_COMPUTE_EX:-slang -compute -dx12 -use-dxil -profile cs_6_0
//TEST(vulkan):COMPARE_COMPUTE_EX:-vk -compute
//TEST:COMPARE_COMPUTE_EX:-cuda -compute

//TEST_INPUT:ubuffer(data=[0 0 0 0], stride=4):out,name outputBuffer
RWStructuredBuffer<int> outputBuffer;

[numthreads(4, 1, 1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID)
{
    int idx = dispatchThreadID.x;
    int laneId = WaveGetLaneIndex();
    // The laneCount will be dependent on target hardware. It seems a count of 1 is valid in spec. 
    // For now we'll just check it's not 0.
    int laneCount = WaveGetLaneCount();
    outputBuffer[idx] = ((laneCount > 0) ? 0x100 : 0) + laneId;
}