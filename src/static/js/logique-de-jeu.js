var jeuSolitaire = (function() {
    "use strict";
    function start_game_ajax(niveau){
        return $.ajax({
            url:'/backend/play',
            data:{'niveau':niveau}
        })
    }
    function coup_ajax(idbille,idpartie,depart,arrivee){
        return $.ajax({
            url:'/backend/coup',
            method:'POST',
            data:{'idbille':idbille,'idpartie':idpartie,'depart':depart,'arrivee':arrivee}
        });
    }
    function end_game(idpartie,score,etat){
        return $.ajax({
            url:'/backend/endgame',
            method:'POST',
            data:{'idpartie':idpartie,'score':score,'etat':etat}
        });
    }
    function is_replay(replay){
        return (replay.length > 0);
    }
    function sleep(milliseconds = 1000) {
        const date = Date.now();
        let currentDate = null;
        do {
            currentDate = Date.now();
        } while (currentDate - date < milliseconds);
    }
// Vars globales*
    var bille = 0,
        idbille = 0,
        idpartie=null,
        replay = [],
        rangBille = null,
        points = 0,
        movements = 0,
        streak = 1,
        activeBille,
        messageTimeout = null,
        partieFini = true,
        map = [],
        boardContainer = document.getElementById("boardContainer"),
        divMovements = document.getElementById("totalMovements"),
        divPoints = document.getElementById("totalPoints"),
        divStreak = document.getElementById("streak"),
        nombreDesBilles = 0;
    /**
     * Public funtions
     */
    var Public = {
        /**
         * Initialisation par niveau
         */
        init: function(niveau=5,replay=[]) {
            var disabled = [1, 2, 6, 7, 8, 9, 13, 14, 36, 37, 41, 42, 43, 44, 48, 49],
                row = 1;
            var casesPleines=[];
            replay = replay
            switch(niveau) {
              case 1:
                    casesPleines=[11,17,18,19,25,32];
                break;
              case 2:
                    casesPleines=[3,4,5,10,11,12,17,18,19,24,26];
                break;
              case 3:
                    casesPleines=[11,17,18,19,23,24,25,26,27,29,30,31,32,33,34,35];
                break;
              case 4:
                    casesPleines=[3,4,5,10,11,12,15,16,17,18,19,20,21,22,23,24,26,27,28,29,30,31,32,33,34,35,38,39,40,45,46,47];
            }

            if(niveau == 5) return false;
            // Videz le plateau si le jeu est redémarré
            boardContainer.innerHTML = "";

            // Construisez des épingles à l'intérieur du tableau*
            for (var i = 1; i <= 49; i++) {
                var div = document.createElement('div');
                if (disabled.indexOf(i) >= 0) {
                    div.className = "square s-" + i + " disabled";
                } else {
                    // Créer une carte des pièces à utiliser pour la vérification du jeu*
                    if (map[i] !== undefined)
                        map.push(i);
                    // Si la broche centrale ajoute la mise en forme des trous, sinon, la mise en forme normale des broches*
                    if ((casesPleines.indexOf(i) >= 0)){
                        div.className = "square s-" + i + " active";
                        div.setAttribute('data-id',i)
                        map[i] = {
                            type: "bille",
                            row: row
                        };
                    }else{
                        div.className = "square s-" + i + " empty";
                        div.setAttribute("data-hole", true);
                        map[i] = {
                            type: "hole",
                            row: row
                        };  
                    }
                    div.addEventListener("click", Private.selectBille);
                }
                div.setAttribute("data-row", row);
                if (i % 7 == 0) {
                    row++;
                }
                div.setAttribute("data-index", i);
                boardContainer.appendChild(div);
                //  // Videz le plateau si le jeu est redémarré
                // boardContainer.innerHTML = "";
            }
        },
        /**
         * rejouer la même partie
         */
        rejeuerPartie: function(niveau,replay=[]) {
            divMovements.innerHTML = "0";
            divPoints.innerHTML = "0";
            divStreak.innerHTML = "0";
            Helper.removeClass(divStreak, "visible");
            Helper.removeClass(boardContainer, "blocked");
            map = [];
            replay = replay
            points = 0;
            idbille = 0;
            movements = 0;
            streak = 1;
            activeBille = null;
            partieFini = true;
            // Appelez à nouveau le 'constructeur' pour remonter le tableau*
            if(is_replay(replay)){
                Public.init(niveau,replay);
                sleep()
            }else{
                start_game_ajax(niveau).then(response => {
                    if(response.action == true){
                        alert("Vous avez commencez une nouvelle partie dans le niveau "+niveau);
                        idpartie = response.idpartie
                        Public.init(niveau);
                    }
                    else{
                        alert(response.msg);
                    }
                });
            }
            
        }
    };

    /**
     * Private funtions
     */
    var Private = {
        /**
         * Fonction de sélection des broches
         */
        selectBille: function() {
            var allowedTarget = this.getAttribute("data-hole") ? true : false;
            // Si la broche est un trou vide (cible autorisée), effectuez les calculs et effectuez les vérifications nécessaires en fonction des données de la broche sélectionnée*
            if (allowedTarget) {
                if (bille > 0) {
                    var autoriserMouvement = false,
                        direction,
                        BilleSupprimerIndex,
                        deletePin,
                        indexCible = parseInt(this.getAttribute("data-index")),
                        billeLigneCible = parseInt(this.getAttribute("data-row")),
                        possibleTargets = [{
                            "position": parseInt(bille + 2),
                            "direction": "r",
                            row: billeLigneCible
                        }, {
                            "position": parseInt(bille - 2),
                            "direction": "l",
                            row: billeLigneCible
                        }, {
                            "position": parseInt(bille + 14),
                            "direction": "b"
                        }, {
                            "position": parseInt(bille - 14),
                            "direction": "t"
                        }];


                    // Vérifie si le mouvement est possible*
                    for (var k in possibleTargets) {
                        if (possibleTargets[k]["position"] == indexCible) {
                            direction = possibleTargets[k]["direction"];
                            // Si le mouvement est à gauche ou à droite, vérifiez si la broche et la cible sont sur la même ligne*
                            if (direction == "l" || direction == "r") {
                                if (possibleTargets[k]["row"] != rangBille) {
                                    autoriserMouvement = false;
                                } else {
                                    autoriserMouvement = true;
                                }
                            } else {
                                autoriserMouvement = true;
                            }
                        }
                    }

                    // Vérifier la direction du mouvement*
                    switch (direction) {
                        case "l":
                            BilleSupprimerIndex = parseInt(bille - 1);
                            break;
                        case "r":
                            BilleSupprimerIndex = parseInt(bille + 1);
                            break;
                        case "b":
                            BilleSupprimerIndex = parseInt(bille + 7);
                            break;
                        case "t":
                            BilleSupprimerIndex = parseInt(bille - 7);
                            break;
                    }
                    deletePin = document.querySelector(".s-" + BilleSupprimerIndex + ".active");


                    // S'il s'agit d'un mouvement autorisé*
                    if (autoriserMouvement && deletePin) {
                        // Passez la goupille dans le nouveau trou*
                        this.removeAttribute("data-hole");
                        Helper.removeClass(this, "empty");
                        Helper.addClass(this, "active");
                        this.setAttribute('data-id',idbille);
                        // Retirez la goupille du trou d'origine*
                        activeBille.setAttribute("data-hole", true);
                        Helper.removeClass(activeBille, "active");
                        Helper.addClass(activeBille, "empty");

                        // Retirez la broche dans la plage de la carte*
                        deletePin = document.querySelector(".s-" + BilleSupprimerIndex);
                        deletePin.setAttribute("data-hole", true);
                        Helper.removeClass(deletePin, "active");
                        Helper.addClass(deletePin, "empty");

                        // Mettre à jour la carte*
                        map[bille].type = "hole";
                        map[BilleSupprimerIndex].type = "hole";
                        map[indexCible].type = "bille";
                        var depart = bille;
                        var arrivee = indexCible;
                        if(!is_replay(replay)){
                            var action = coup_ajax(idbille,idpartie,depart,arrivee).then(response => {
                                return response.action;
                            });
                            if(!action){
                                alert('Something went wrong')
                                return false;
                            }
                        }
                        // Augmente les points, les mouvements et les séquences du joueur. 
                        movements++;
                        points += streak * 10;
                        // Réinitialiser la broche sélectionnée*
                        bille = 0;
                        // Insérez les statistiques des joueurs dans le DOM (nombre de coups, scores et séquence)*
                        if (streak >= 2) {
                            divStreak.innerHTML = "x" + streak;
                            Helper.addClass(divStreak, "visible");
                        }
                        divMovements.innerHTML = movements;
                        divPoints.innerHTML = points;

                        // Vérifiez la partie*
                        partieFini = Private.checkPartieFinie();
                        nombreDesBilles = document.querySelectorAll('.active').length;


                        if (partieFini && nombreDesBilles!=1) {
                            Private.afficheMessage("PERDU");
                            end_game(idpartie,points,0).then(response => {
                                $('#score').html(response.score)
                            });
                            Helper.addClass(boardContainer, "blocked");
                        }else if (partieFini && nombreDesBilles==1){
                            Private.afficheMessage("GAGNE");
                            end_game(idpartie,points,1).then(response => {
                                $('#score').html(response.score)
                            });
                            Helper.addClass(boardContainer, "blocked");
                        }



                    } else {
                        Private.afficheMessage("Vous ne pouvez pas effectuer ce mouvement");
                        return;
                    }
                } else {
                    Private.afficheMessage("Aucune bille sélectionnée");
                    return;
                }
            } else {
                // Si la sélection n'est pas un trou vide, affectez les données de la broche sélectionnée aux variables*
                var activeClass = this.className,
                    toutBilles = document.getElementsByClassName("active");

                // Index des broches*
                bille = parseInt(this.getAttribute("data-index"));
                idbille = parseInt(this.getAttribute("data-id"));
                rangBille = parseInt(this.getAttribute("data-row"));
                // Élément de broche actuellement actif*
                activeBille = this;

                    // Attribuer une mise en forme spéciale à la broche sélectionnée (retour visuel)*
                    if (Helper.hasClass(this, "selected")) {
                    this.classList.remove("selected");
                    bille = 0;
                } else {
                    for (var b = 0; b <= toutBilles.length; b++) {
                        Helper.removeClass(toutBilles[b], "selected");
                    }
                    Helper.addClass(this, "selected");
                }
            }
        },

        /**
         * Message de déclenchement
          * @param {String} message - Texte du message
         */
        afficheMessage: function(message) {
            var divMessage = document.getElementById("message");

            if (message) {
                divMessage.textContent = message;
                Helper.addClass(divMessage, "visible");

                if (messageTimeout) {
                    clearTimeout(messageTimeout);
                    messageTimeout = null;
                }
                messageTimeout = setTimeout(function() {
                    Helper.removeClass(divMessage, "visible");
                }, 3000);
            } else {
                console.warn("Paramétre 'message' invalide.");
            }
        },

        /**
         * fonction game over check
         */
        checkPartieFinie: function() {
            var toutBilles = document.querySelectorAll("div[data-hole='true']");
            for (var b = 0; b <= toutBilles.length; b++) {
                if (toutBilles[b]) {
                    var indexTrou = parseInt(toutBilles[b].getAttribute("data-index")),
                        rangTrouBille = parseInt(toutBilles[b].getAttribute("data-row"))
                        //top
                    if (map[(indexTrou - 7)] && map[(indexTrou - 14)]) {
                        if (map[(indexTrou - 7)].type == "bille" && map[(indexTrou - 14)].type == "bille") {
                            partieFini = false;
                            break;
                        } else {
                            partieFini = true;
                        }
                    }
                    //bottom
                    if (map[(indexTrou + 7)] && map[(indexTrou + 14)]) {
                        if (map[(indexTrou + 7)].type == "bille" && map[(indexTrou + 14)].type == "bille") {
                            partieFini = false;
                            break;
                        } else {
                            partieFini = true;
                        }
                    }
                    //left
                    if (map[(indexTrou - 1)] && map[(indexTrou - 2)]) {
                        if (map[(indexTrou - 1)].type == "bille" && map[(indexTrou - 2)].type == "bille") {
                            if (rangTrouBille == map[(indexTrou - 1)].row && rangTrouBille == map[(indexTrou - 2)].row) {
                                partieFini = false;
                                break;
                            } else {
                                partieFini = true;
                            }
                        }
                    }
                    //right
                    if (map[(indexTrou + 1)] && map[(indexTrou + 2)]) {
                        if (map[(indexTrou + 1)] == "bille" && map[(indexTrou + 2)] == "bille") {
                            if (rangTrouBille == map[(indexTrou - 1)].row && rangTrouBille == map[(indexTrou - 2)].row) {
                                partieFini = false;
                                break;
                            } else {
                                partieFini = true;
                            }
                        }
                    }
                }
            }
            return partieFini;
        }
    };

    return Public;
})();
// jeuSolitaire.init();