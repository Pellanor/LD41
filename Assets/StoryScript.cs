using Ink.Runtime;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class StoryScript : MonoBehaviour {

    [SerializeField]
    private TextAsset inkJSONAsset;
    private Story story;

    [SerializeField]
    private Canvas canvas;

    // UI Prefabs
    [SerializeField]
    private Text textPrefab;
    [SerializeField]
    private Button buttonPrefab;

    private float curTime = 0;
    private float lastGatherTime = 0;

    private LinkedList<AsyncCall> asyncCalls = new LinkedList<AsyncCall>();

    private static Dictionary<string, int> quantities = new Dictionary<string, int>
        {
            { "single", 1 },
            { "few", 5 },
            { "squad", 10 },
            { "section", 25 },
            { "platoon", 50 },
            { "company", 200 },
        };

    void Update()
    {
        curTime = (float)story.variablesState["time"] + Time.deltaTime;
        story.variablesState["time"] = curTime;

        if (curTime - lastGatherTime > (float)story.variablesState["resource_delta"])
        {
            lastGatherTime = curTime;
            story.variablesState["resources"] = (int)story.variablesState["resources"] + (int)story.variablesState["resource_rate"];
        }

        var callNode = asyncCalls.First;
        while (callNode != null)
        {
            var next = callNode.Next;
            if (callNode.Value.executeTime < curTime)
            {
                callNode.Value.Execute(story);
                asyncCalls.Remove(callNode);
            }
            callNode = next;
        }
    }

    void Awake()
    {
        StartStory();
    }

    void StartStory()
    {
        story = new Story(inkJSONAsset.text);
        story.BindExternalFunction("trunc", (float x) => { return Mathf.FloorToInt(x); });
        RefreshView();
    }

    void RefreshView()
    {
        RemoveChildren();

        while (story.canContinue)
        {
            string text = story.Continue().Trim();
            CreateContentView(text);
            foreach (var tag in story.currentTags)
            {
                if (tag == "async")
                {
                    int index = story.currentTags.IndexOf("async");
                    string func = story.currentTags[index + 1];
//                    object[] varargs = story.currentTags.GetRange(index + 3, story.currentTags.Count - (index + 3)).ToArray();
                    if (func == "add_resources")
                    {
                        int resources = System.Int32.Parse(story.currentTags[index + 2]);
                        int delta = System.Int32.Parse(story.currentTags[index + 3]);
                        asyncCalls.AddLast(AsyncCall.AddResources(delta + curTime, resources));
                    }
                    else if (func == "train")
                    {
                        int quantity = quantities[story.currentTags[index + 2]];
                        string unit = story.currentTags[index + 3];
                        int delta = (int)story.variablesState[unit + "_time"];
                        asyncCalls.AddLast(AsyncCall.Train(unit, delta + curTime, quantity));
                    }
                    else if (func == "toggle")
                    {
                        string var = story.currentTags[index + 2];
                        bool newVal = !(bool)story.variablesState[var];
                        int delta = System.Int32.Parse(story.currentTags[index + 3]);
                        asyncCalls.AddLast(AsyncCall.SetVar(var, newVal, delta + curTime));
                    }
                    else if (func == "set")
                    {
                        string var = story.currentTags[index + 2];
                        int delta = System.Int32.Parse(story.currentTags[index + 3]);
                        asyncCalls.AddLast(AsyncCall.SetVar(var, true, delta + curTime));
                    }
                    else
                    {
                        int delta = System.Int32.Parse(story.currentTags[index + 2]);
                        asyncCalls.AddLast(AsyncCall.CallFunc(func, delta + curTime));
                    }
                }
            }
        }

        if (story.currentChoices.Count > 0)
        {
            for (int i = 0; i < story.currentChoices.Count; i++)
            {
                Choice choice = story.currentChoices[i];
                Button button = CreateChoiceView(choice.text.Trim());
                button.onClick.AddListener(delegate {
                    OnClickChoiceButton(choice);
                });
            }
        }
        else
        {
            Button choice = CreateChoiceView("End of story.\nRestart?");
            choice.onClick.AddListener(delegate {
                StartStory();
            });
        }
    }

    void OnClickChoiceButton(Choice choice)
    {
        story.ChooseChoiceIndex(choice.index);
        RefreshView();
    }

    void CreateContentView(string text)
    {
        Text storyText = Instantiate(textPrefab) as Text;
        storyText.text = text;
        storyText.transform.SetParent(canvas.transform, false);
    }

    Button CreateChoiceView(string text)
    {
        Button choice = Instantiate(buttonPrefab) as Button;
        choice.transform.SetParent(canvas.transform, false);

        Text choiceText = choice.GetComponentInChildren<Text>();
        choiceText.text = text;

        HorizontalLayoutGroup layoutGroup = choice.GetComponent<HorizontalLayoutGroup>();
        layoutGroup.childForceExpandHeight = false;

        return choice;
    }

    void RemoveChildren()
    {
        int childCount = canvas.transform.childCount;
        for (int i = childCount - 1; i >= 0; --i)
        {
            GameObject.Destroy(canvas.transform.GetChild(i).gameObject);
        }
    }

    private class AsyncCall
    {
        private string func;
        public float executeTime;
        private object[] vars;
        private bool isVar = false;

        public static AsyncCall AddResources(float executionTime, int resources)
        {
            return new AsyncCall("add_resources", executionTime, resources);
        }

        public static AsyncCall Train(string unit, float executionTime, int quantity)
        {
            return new AsyncCall("train_"+unit, executionTime, quantity);
        }

        public static AsyncCall SetVar(string var, object val, float executionTIme)
        {
            return new AsyncCall(true, var, executionTIme, val);
        }

        public static AsyncCall CallFunc(string func, float executionTime)
        {
            return new AsyncCall(func, executionTime);
        }

        private AsyncCall(string func, float executeTime, params object[] vars)
        {
            this.func = func;
            this.executeTime = executeTime;
            this.vars = vars;
            isVar = false;
        }

        private AsyncCall(bool isVar, string variable, float executeTime, object val)
        {
            this.func = variable;
            this.executeTime = executeTime;
            this.vars = new object[] { val };
            this.isVar = isVar;
        }

        public void Execute(Story story)
        {
            if (isVar)
            {
                // #theHacksAreReal
                story.variablesState[func] = vars[0];
            }
            else
            {
                story.EvaluateFunction(func, vars);
            }
        }
    }
}
