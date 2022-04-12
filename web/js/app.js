function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

const app = Vue.createApp({
    el: '#app',
    data() {
        return {
            message: 'Click the button below for an easy way to try out Kontain in a trial environment',
            waitMessage: '',
            userEnvLink: '',
            useEnvMessage: '',
            info: null
        }
    },
    // this is the mounted App lifecycle hook used for populating the data from server at display time
    mounted () {
        // axios
        //   .get('https://api.coindesk.com/v1/bpi/currentprice.json')
        //   .then(response => (this.info = response))
      },
    methods: {
        tryKontainBtnClick() {
            this.waitMessage = 'Please wait for a few seconds! We are launching your environment...'
            this.provision()
        },

        async provision() {
            console.log('entered provisioning...')
            const response = await axios.get("/api/env/newenv")

            // try {
            //     response = await axios.get("/api/env/newenv")
            // }catch(err) {
            //     if (err.response) {
            //         // The client was given an error response (5xx, 4xx)
            //         console.log(err.response.data);
            //         console.log(err.response.status);
            //         console.log(err.response.headers);
            //     } else if (err.request) {
            //         // The client never received a response, and the request was never left
            //     } else {
            //         // Anything else
            //     }
            // }

            console.log(response)
            await sleep(5000)

            this.waitMessage = "Your environment is ready. Please click the link below to use your environment"
            this.userEnvLink = response.data.result // "https://google.com"
            this.useEnvMessage = "Your Kontain environment"

            // async fn() and await above replaces sleep().then().sleep().then()...  sequence
            // sleep(5000).then(() => { 
            //     console.log("finished provisioning environment");

            //     this.waitMessage = "Finished provisioning your environment. Please click the link below to enter your environment"
            //     this.userEnvLink = "https://google.com"
            // });
        }
    }
});

app.mount('#app')
