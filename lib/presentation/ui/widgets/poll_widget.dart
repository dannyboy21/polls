import 'package:flutter/material.dart';
import 'package:my_pwa_app/presentation/ui/admin/poll_votes_detail_page.dart';
import 'package:my_pwa_app/presentation/utils/colors.dart';

class PollWidget extends StatelessWidget {
  final String pollId;
  final int unitsNumber; // Total de residentes
  final bool isDarkMode;
  final bool isAdmin;
  final String title;
  final String answer;
  final String startingDate;
  final String startingTime;
  final String endingDate;
  final String endingTime;
  final String status;
  final List<String> options;
  final List<int> votes; // Votos por opción
  final bool hasVoted; // Si el residente ya votó
  final void Function(int) onVote; // Acción de votar
  final int?
      selectedVoteIndex; // Índice de la opción seleccionada por el usuario

  PollWidget({
    required this.pollId,
    required this.unitsNumber,
    required this.isDarkMode,
    required this.isAdmin,
    required this.title,
    required this.answer,
    required this.startingDate,
    required this.startingTime,
    required this.endingDate,
    required this.endingTime,
    required this.status,
    required this.options,
    required this.votes,
    required this.hasVoted,
    required this.onVote,
    this.selectedVoteIndex,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case "En curso":
        return AppColors.acceptColor; // Verde para "En curso"
      case "Finalizada":
        return AppColors.rejectColor; // Rojo para "Finalizada"
      default:
        return Colors.grey; // Color predeterminado
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalVotes = votes.fold(0, (sum, vote) => sum + vote);

    // Encontrar la opción más votada
    int maxVotes = votes.isNotEmpty ? votes.reduce((a, b) => a > b ? a : b) : 0;
    String mostVotedOption = votes.contains(maxVotes)
        ? options[votes.indexOf(maxVotes)]
        : "No hay votos";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(width: 0.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la encuesta
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? Colors.lightBlue
                      : const Color.fromARGB(255, 29, 56, 207),
                ),
              ),
              const SizedBox(height: 10),

              // Fechas de inicio y cierre
              Row(
                children: [
                  Text("Inicio: $startingDate $startingTime"),
                ],
              ),
              Row(
                children: [
                  Text("Cierre: $endingDate $endingTime"),
                ],
              ),
              const SizedBox(height: 10),

              // Estado de la encuesta
              Row(
                children: [
                  const Text("Estado: "),
                  Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Texto para seleccionar una opción
              if (!isAdmin && !hasVoted && status != "Finalizada")
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Row(
                    children: [
                      Text(
                        "Selecciona una opción:",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),

              // Opciones de la encuesta
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  int voteCount = votes[index];

                  // Porcentaje basado en el número total de residentes
                  double percentage =
                      unitsNumber > 0 ? (voteCount / unitsNumber) * 100 : 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Mostrar check_circle si el usuario ha votado en esta opción
                              if (hasVoted && selectedVoteIndex == index)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                )
                              else if (!hasVoted &&
                                  !isAdmin &&
                                  status != "Finalizada")
                                GestureDetector(
                                  onTap: () {
                                    onVote(index); // Registrar el voto
                                  },
                                  child: const Icon(
                                    Icons.circle_outlined,
                                    size: 20,
                                  ),
                                ),
                              const SizedBox(width: 10),
                              Text(
                                option,
                                style: TextStyle(
                                  fontWeight:
                                      hasVoted && selectedVoteIndex == index
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: hasVoted && selectedVoteIndex == index
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                              ),
                            ],
                          ),

                          // Mostrar el conteo de votos junto a cada opción
                          Text(
                            "$voteCount ${voteCount == 1 ? 'voto' : 'votos'}",
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // Total de votos
              Row(
                children: [
                  const Text(
                    "Total de votos: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("$totalVotes de $unitsNumber"),
                ],
              ),
              const SizedBox(height: 10),

              // Mostrar opción más votada si el estado es "Finalizada"
              if (status == "Finalizada")
                Text(
                  'Opción ganadora: "$mostVotedOption"',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentColor,
                      fontSize: 16),
                ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PollVotesDetailPage(
                                    votes: votes,
                                    pollId: pollId,
                                    options: options,
                                    isDarkMode: isDarkMode,
                                    title: title,
                                    winner: mostVotedOption,
                                  )));
                    },
                    child: const Text("Ver votos")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
